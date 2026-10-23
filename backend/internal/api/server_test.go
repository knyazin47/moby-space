package api

import (
	"bufio"
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

const testSecret = "synthetic-test-only-bootstrap-32-characters"

type fixture struct {
	t     *testing.T
	s     *Server
	http  *httptest.Server
	token string
}

func setup(t *testing.T) *fixture {
	t.Helper()
	s, e := New(Config{DatabasePath: filepath.Join(t.TempDir(), "family.sqlite"), BootstrapSecret: testSecret})
	if e != nil {
		t.Fatal(e)
	}
	f := &fixture{t: t, s: s, http: httptest.NewServer(s)}
	t.Cleanup(func() { f.http.Close(); s.Close() })
	_, v := f.call("POST", "/v1/auth/adult", "", map[string]any{"bootstrapSecret": testSecret, "deviceName": "parent"})
	f.token = v["token"].(string)
	return f
}
func (f *fixture) call(method, path, token string, in any) (int, map[string]any) {
	f.t.Helper()
	b, _ := json.Marshal(in)
	req, _ := http.NewRequest(method, f.http.URL+path, bytes.NewReader(b))
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	res, e := f.http.Client().Do(req)
	if e != nil {
		f.t.Fatal(e)
	}
	defer res.Body.Close()
	data, _ := io.ReadAll(res.Body)
	v := map[string]any{}
	if len(data) > 0 && data[0] == '{' {
		if e = json.Unmarshal(data, &v); e != nil {
			f.t.Fatal(e)
		}
	}
	return res.StatusCode, v
}
func (f *fixture) child(name string) string {
	code, v := f.call("POST", "/v1/children", f.token, map[string]any{"displayName": name, "legalName": "Synthetic " + name, "dateOfBirth": "2015-01-02"})
	if code != 201 {
		f.t.Fatalf("create %d %v", code, v)
	}
	return v["id"].(string)
}
func (f *fixture) pair(child string) (string, string) {
	_, p := f.call("POST", "/v1/pairings", "", map[string]any{"deviceName": "child phone"})
	code, v := f.call("POST", "/v1/pairings/consume", f.token, map[string]any{"code": p["code"], "childId": child})
	if code != 200 {
		f.t.Fatalf("consume %d %v", code, v)
	}
	code, v = f.call("POST", "/v1/pairings/"+p["id"].(string)+"/poll", "", map[string]any{"requestSecret": p["requestSecret"]})
	if code != 200 {
		f.t.Fatalf("poll %d %v", code, v)
	}
	session := v["session"].(map[string]any)
	return session["token"].(string), session["actor"].(map[string]any)["sessionId"].(string)
}
func TestFamilyOwnershipAndPersistence(t *testing.T) {
	f := setup(t)
	_, initial := f.call("GET", "/v1/snapshot", f.token, nil)
	if len(initial["children"].([]any)) != 0 {
		t.Fatal("seed children forbidden")
	}
	a, b := f.child("A"), f.child("B")
	ta, _ := f.pair(a)
	tb, _ := f.pair(b)
	for _, tt := range []struct {
		method, path, token string
		body                any
		want                int
	}{{"GET", "/v1/children/" + b, ta, nil, 403}, {"PATCH", "/v1/children/" + a, ta, map[string]any{"displayName": "hack"}, 403}, {"POST", "/v1/children", tb, map[string]any{"displayName": "hack"}, 403}, {"GET", "/v1/sessions", ta, nil, 403}} {
		code, v := f.call(tt.method, tt.path, tt.token, tt.body)
		if code != tt.want {
			t.Fatalf("scope %d %v", code, v)
		}
	}
	_, snap := f.call("GET", "/v1/snapshot", ta, nil)
	children := snap["children"].([]any)
	if len(children) != 1 || children[0].(map[string]any)["id"] != a {
		t.Fatal("scope leaked")
	}
	path := f.s.cfg.DatabasePath
	f.s.Close()
	s, e := New(Config{DatabasePath: path, BootstrapSecret: testSecret})
	if e != nil {
		t.Fatal(e)
	}
	f.http.Close()
	f.s = s
	f.http = httptest.NewServer(s)
	_, snap = f.call("GET", "/v1/snapshot", ta, nil)
	if len(snap["children"].([]any)) != 1 {
		t.Fatal("restart lost family/session")
	}
	f.call("POST", "/v1/children/"+a+"/archive", f.token, nil)
	code, _ := f.call("GET", "/v1/snapshot", ta, nil)
	if code != 401 {
		t.Fatal("archive did not revoke")
	}
	code, _ = f.call("GET", "/v1/snapshot", tb, nil)
	if code != 200 {
		t.Fatal("unrelated child revoked")
	}
}
func TestPairingSecretReplayCancelExpireConcurrency(t *testing.T) {
	f := setup(t)
	child := f.child("A")
	_, p := f.call("POST", "/v1/pairings", "", map[string]string{"deviceName": "phone"})
	path := "/v1/pairings/" + p["id"].(string) + "/poll"
	code, _ := f.call("POST", path, "", map[string]string{"requestSecret": "wrong"})
	if code != 404 {
		t.Fatal("wrong request secret accepted")
	}
	var successes atomic.Int32
	var wg sync.WaitGroup
	for range 6 {
		wg.Go(func() {
			code, _ := f.call("POST", "/v1/pairings/consume", f.token, map[string]any{"code": p["code"], "childId": child})
			if code == 200 {
				successes.Add(1)
			}
		})
	}
	wg.Wait()
	if successes.Load() != 1 {
		t.Fatalf("consume executions %d", successes.Load())
	}
	successes.Store(0)
	for range 6 {
		wg.Go(func() {
			code, v := f.call("POST", path, "", map[string]any{"requestSecret": p["requestSecret"]})
			if code == 200 && v["session"] != nil {
				successes.Add(1)
			}
		})
	}
	wg.Wait()
	if successes.Load() != 6 {
		t.Fatalf("retry deliveries %d", successes.Load())
	}
	f.s.mu.Lock()
	childSessions := 0
	for _, a := range f.s.state.Sessions {
		if a.Role == "child" {
			childSessions++
		}
	}
	f.s.mu.Unlock()
	if childSessions != 1 {
		t.Fatal("poll minted duplicate sessions")
	}
	_, cancel := f.call("POST", "/v1/pairings", "", map[string]string{"deviceName": "phone"})
	f.call("POST", "/v1/pairings/"+cancel["id"].(string)+"/cancel", "", map[string]any{"requestSecret": cancel["requestSecret"]})
	code, _ = f.call("POST", "/v1/pairings/consume", f.token, map[string]any{"code": cancel["code"], "childId": child})
	if code != 409 {
		t.Fatal("cancelled pair consumed")
	}
	_, expired := f.call("POST", "/v1/pairings", "", map[string]string{"deviceName": "phone"})
	f.s.mu.Lock()
	st := clone(f.s.state)
	st.Pairings[expired["id"].(string)].ExpiresAt = time.Now().Add(-time.Minute).Unix()
	_ = f.s.save(st)
	f.s.mu.Unlock()
	code, _ = f.call("POST", "/v1/pairings/consume", f.token, map[string]any{"code": expired["code"], "childId": child})
	if code != 410 {
		t.Fatal("expired pair consumed")
	}
}
func stream(t *testing.T, f *fixture, token string) (*http.Response, *bufio.Reader) {
	t.Helper()
	req, _ := http.NewRequest("GET", f.http.URL+"/v1/events", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	res, e := f.http.Client().Do(req)
	if e != nil {
		t.Fatal(e)
	}
	if res.StatusCode != 200 {
		t.Fatal("stream unauthorized")
	}
	return res, bufio.NewReader(res.Body)
}
func event(t *testing.T, r *bufio.Reader) map[string]any {
	t.Helper()
	for {
		line, e := r.ReadString('\n')
		if e != nil {
			t.Fatal(e)
		}
		if strings.HasPrefix(line, "data: ") {
			var v map[string]any
			if e = json.Unmarshal([]byte(strings.TrimPrefix(line, "data: ")), &v); e != nil {
				t.Fatal(e)
			}
			return v
		}
	}
}
func TestThreeClientsSSEReconnectLogoutRevoke(t *testing.T) {
	f := setup(t)
	a, b := f.child("A"), f.child("B")
	ta, sa := f.pair(a)
	tb, _ := f.pair(b)
	pa, ra := stream(t, f, ta)
	defer pa.Body.Close()
	pb, rb := stream(t, f, tb)
	defer pb.Body.Close()
	pp, rp := stream(t, f, f.token)
	defer pp.Body.Close()
	event(t, ra)
	event(t, rb)
	event(t, rp)
	p := Policy{Payments: false, Transfers: true, Internet: false, DailyLimit: 100, MonthlyLimit: 200, ApprovalThreshold: 50}
	code, _ := f.call("PATCH", "/v1/children/"+a+"/policy", f.token, p)
	if code != 200 {
		t.Fatal("update policy")
	}
	ea, eb, ep := event(t, ra), event(t, rb), event(t, rp)
	if len(ep["children"].([]any)) != 2 || len(ea["children"].([]any)) != 1 || len(eb["children"].([]any)) != 1 {
		t.Fatal("live scope")
	}
	if ea["children"].([]any)[0].(map[string]any)["policy"].(map[string]any)["payments"] != false || eb["children"].([]any)[0].(map[string]any)["policy"].(map[string]any)["payments"] != true {
		t.Fatal("child settings cross talk")
	}
	reconnect, rr := stream(t, f, ta)
	defer reconnect.Body.Close()
	if event(t, rr)["revision"] != ea["revision"] {
		t.Fatal("reconnect lost revision")
	}
	f.call("POST", "/v1/sessions/"+sa+"/revoke", f.token, nil)
	done := make(chan error, 1)
	go func() { _, e := io.ReadAll(pa.Body); done <- e }()
	select {
	case <-done:
	case <-time.After(2 * time.Second):
		t.Fatal("revoked SSE stayed open")
	}
	f.call("POST", "/v1/auth/logout", tb, nil)
	logoutDone := make(chan error, 1)
	go func() { _, e := io.ReadAll(pb.Body); logoutDone <- e }()
	select {
	case <-logoutDone:
	case <-time.After(2 * time.Second):
		t.Fatal("logout SSE stayed open")
	}
	code, _ = f.call("GET", "/v1/snapshot", tb, nil)
	if code != 401 {
		t.Fatal("logout token remains valid")
	}
	code, _ = f.call("GET", "/v1/snapshot", f.token, nil)
	if code != 200 {
		t.Fatal("logout destroyed family")
	}
}
func TestRequestValidationAndStoredHashes(t *testing.T) {
	f := setup(t)
	code, _ := f.call("POST", "/v1/auth/adult", "", map[string]string{"bootstrapSecret": "wrong"})
	if code != 401 {
		t.Fatal("public bootstrap")
	}
	code, _ = f.call("POST", "/v1/children", f.token, map[string]any{"displayName": "x", "dateOfBirth": "2015-01-02", "role": "adult"})
	if code != 400 {
		t.Fatal("trusted client role")
	}
	code, _ = f.call("POST", "/v1/pairings", "", map[string]string{"deviceName": strings.Repeat("x", 9000)})
	if code != 400 {
		t.Fatal("oversize")
	}
	var raw string
	if e := f.s.db.QueryRow("SELECT document FROM family_state").Scan(&raw); e != nil {
		t.Fatal(e)
	}
	if strings.Contains(raw, f.token) || strings.Contains(raw, testSecret) {
		t.Fatal("plaintext credentials persisted")
	}
}

func TestChildCreateIdempotencyRestartRelogin(t *testing.T) {
	f := setup(t)
	body := map[string]any{"displayName": "Retry child", "legalName": "Synthetic Retry", "dateOfBirth": "2014-07-11", "idempotencyKey": "create-child-persistent-1"}
	code, original := f.call("POST", "/v1/children", f.token, body)
	if code != 201 {
		t.Fatal(original)
	}
	var successes atomic.Int32
	var wg sync.WaitGroup
	for range 4 {
		wg.Go(func() {
			code, v := f.call("POST", "/v1/children", f.token, body)
			if code == 200 && v["id"] == original["id"] {
				successes.Add(1)
			}
		})
	}
	wg.Wait()
	if successes.Load() != 4 {
		t.Fatal("concurrent create retry duplicated")
	}
	dbPath := f.s.cfg.DatabasePath
	f.http.Close()
	f.s.Close()
	s, e := New(Config{DatabasePath: dbPath, BootstrapSecret: testSecret})
	if e != nil {
		t.Fatal(e)
	}
	f.s = s
	f.http = httptest.NewServer(s)
	_, login := f.call("POST", "/v1/auth/adult", "", map[string]any{"bootstrapSecret": testSecret, "deviceName": "new parent session"})
	token := login["token"].(string)
	code, v := f.call("POST", "/v1/children", token, body)
	if code != 200 || v["id"] != original["id"] {
		t.Fatal("restart/relogin lost create idempotency")
	}
	body["displayName"] = "Different payload"
	code, _ = f.call("POST", "/v1/children", token, body)
	if code != 409 {
		t.Fatal("conflicting create payload accepted")
	}
	_, snap := f.call("GET", "/v1/snapshot", token, nil)
	if len(snap["children"].([]any)) != 1 {
		t.Fatal("retry created extra profile")
	}
}
