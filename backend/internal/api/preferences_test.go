package api

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"testing"
)

const familyIntroPath = "/v1/preferences/family-intro/complete"

func assertFamilyIntro(t *testing.T, snapshot map[string]any, seen bool) {
	t.Helper()
	preferences, ok := snapshot["preferences"].(map[string]any)
	if !ok || preferences["familyIntroSeen"] != seen {
		t.Fatalf("family intro preference: want %t, got %v", seen, snapshot["preferences"])
	}
}

func TestFamilyIntroPersistenceIndependentOfChildrenAndSessions(t *testing.T) {
	path := filepath.Join(t.TempDir(), "family.sqlite")
	newServer := func() *Server {
		s, err := New(Config{DatabasePath: path, BootstrapSecret: testSecret})
		if err != nil {
			t.Fatal(err)
		}
		return s
	}
	f := &fixture{t: t, s: newServer()}
	f.http = httptest.NewServer(f.s)
	t.Cleanup(func() { f.http.Close(); f.s.Close() })
	login := func(device string) string {
		status, session := f.call("POST", "/v1/auth/adult", "", map[string]any{"bootstrapSecret": testSecret, "deviceName": device})
		if status != 200 {
			t.Fatalf("login: %d %v", status, session)
		}
		return session["token"].(string)
	}
	f.token = login("parent")
	_, initial := f.call("GET", "/v1/snapshot", f.token, nil)
	assertFamilyIntro(t, initial, false)
	if len(initial["children"].([]any)) != 0 {
		t.Fatal("expected empty family")
	}
	actorID := initial["actor"].(map[string]any)["id"]
	status, completed := f.call("POST", familyIntroPath, f.token, struct{}{})
	if status != 200 || completed["revision"].(float64) != initial["revision"].(float64)+1 {
		t.Fatalf("completion must commit exactly once: %d %v", status, completed)
	}
	assertFamilyIntro(t, completed, true)
	status, repeated := f.call("POST", familyIntroPath, f.token, struct{}{})
	if status != 200 || repeated["revision"] != completed["revision"] {
		t.Fatalf("retry must not commit another revision: %d %v", status, repeated)
	}
	assertFamilyIntro(t, repeated, true)
	secondToken := login("second adult device")
	_, second := f.call("GET", "/v1/snapshot", secondToken, nil)
	assertFamilyIntro(t, second, true)
	if second["actor"].(map[string]any)["id"] != actorID {
		t.Fatal("adult preference must belong to permanent actor")
	}
	childID := f.child("A")
	status, archived := f.call("POST", "/v1/children/"+childID+"/archive", f.token, nil)
	if status != 200 {
		t.Fatalf("archive: %d %v", status, archived)
	}
	_, afterArchive := f.call("GET", "/v1/snapshot", f.token, nil)
	assertFamilyIntro(t, afterArchive, true)
	for _, child := range afterArchive["children"].([]any) {
		if child.(map[string]any)["membershipStatus"] != "archived" {
			t.Fatal("expected no active children after archiving last child")
		}
	}
	status, _ = f.call("POST", "/v1/auth/logout", f.token, nil)
	if status != 200 {
		t.Fatal("logout failed")
	}
	f.token = login("parent relogin")
	_, relogged := f.call("GET", "/v1/snapshot", f.token, nil)
	assertFamilyIntro(t, relogged, true)
	f.http.Close()
	if err := f.s.Close(); err != nil {
		t.Fatal(err)
	}
	f.s = newServer()
	f.http = httptest.NewServer(f.s)
	status, restarted := f.call("GET", "/v1/snapshot", secondToken, nil)
	if status != 200 {
		t.Fatalf("persisted device session: %d", status)
	}
	assertFamilyIntro(t, restarted, true)
	f.token = login("post-restart relogin")
	_, restartedLogin := f.call("GET", "/v1/snapshot", f.token, nil)
	assertFamilyIntro(t, restartedLogin, true)
	if restartedLogin["actor"].(map[string]any)["id"] != actorID {
		t.Fatal("restart changed adult actor")
	}
}

func TestFamilyIntroLegacyStateDefaultsFalse(t *testing.T) {
	path := filepath.Join(t.TempDir(), "family.sqlite")
	cfg := Config{DatabasePath: path, BootstrapSecret: testSecret}
	s, err := New(cfg)
	if err != nil {
		t.Fatal(err)
	}
	// Simulate an aggregate persisted before adult preferences existed.
	raw, err := json.Marshal(s.state)
	if err != nil {
		t.Fatal(err)
	}
	var legacy map[string]json.RawMessage
	if err := json.Unmarshal(raw, &legacy); err != nil {
		t.Fatal(err)
	}
	delete(legacy, "preferences")
	raw, err = json.Marshal(legacy)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := s.db.Exec("UPDATE family_state SET document=? WHERE id=1", string(raw)); err != nil {
		t.Fatal(err)
	}
	if err := s.Close(); err != nil {
		t.Fatal(err)
	}
	s, err = New(cfg)
	if err != nil {
		t.Fatal(err)
	}
	defer s.Close()
	if s.state.Preferences.FamilyIntroSeen {
		t.Fatal("legacy persisted aggregate must default to unseen")
	}
	snapshot := s.snapshot(&Session{Role: "adult"})
	if snapshot.Preferences == nil || snapshot.Preferences.FamilyIntroSeen {
		t.Fatal("legacy adult snapshot must explicitly expose false")
	}
}

func TestFamilyIntroAdultOnlyScopedSnapshotAndEvents(t *testing.T) {
	f := setup(t)
	a, b := f.child("A"), f.child("B")
	ta, _ := f.pair(a)
	tb, _ := f.pair(b)
	_, before := f.call("GET", "/v1/snapshot", f.token, nil)
	for _, token := range []string{ta, tb} {
		status, snapshot := f.call("GET", "/v1/snapshot", token, nil)
		if status != 200 {
			t.Fatal("child snapshot failed")
		}
		if _, exists := snapshot["preferences"]; exists {
			t.Fatal("adult preference leaked into child snapshot")
		}
		status, _ = f.call("POST", familyIntroPath, token, struct{}{})
		if status != 403 {
			t.Fatalf("child completion must be forbidden: %d", status)
		}
	}
	status, _ := f.call("POST", familyIntroPath, "", struct{}{})
	if status != 401 {
		t.Fatalf("anonymous completion must require authentication: %d", status)
	}
	_, afterDenied := f.call("GET", "/v1/snapshot", f.token, nil)
	assertFamilyIntro(t, afterDenied, false)
	if afterDenied["revision"] != before["revision"] {
		t.Fatal("forbidden commands changed state")
	}
	adultResponse, adultEvents := stream(t, f, f.token)
	defer adultResponse.Body.Close()
	aResponse, aEvents := stream(t, f, ta)
	defer aResponse.Body.Close()
	bResponse, bEvents := stream(t, f, tb)
	defer bResponse.Body.Close()
	assertFamilyIntro(t, event(t, adultEvents), false)
	for _, snapshot := range []map[string]any{event(t, aEvents), event(t, bEvents)} {
		if _, exists := snapshot["preferences"]; exists {
			t.Fatal("adult preference leaked into initial child event")
		}
	}
	status, completed := f.call("POST", familyIntroPath, f.token, struct{}{})
	if status != 200 {
		t.Fatalf("completion: %d %v", status, completed)
	}
	adultSnapshot := event(t, adultEvents)
	assertFamilyIntro(t, adultSnapshot, true)
	if adultSnapshot["revision"] != completed["revision"] {
		t.Fatal("adult event did not expose committed revision")
	}
	for i, snapshot := range []map[string]any{event(t, aEvents), event(t, bEvents)} {
		if _, exists := snapshot["preferences"]; exists {
			t.Fatal("adult preference leaked into child update event")
		}
		children := snapshot["children"].([]any)
		if len(children) != 1 || children[0].(map[string]any)["id"] != []string{a, b}[i] {
			t.Fatal("child scope changed after adult preference update")
		}
		if snapshot["revision"] != completed["revision"] {
			t.Fatal("child event revision is not current")
		}
	}
	reconnected, reconnectedEvents := stream(t, f, f.token)
	defer reconnected.Body.Close()
	assertFamilyIntro(t, event(t, reconnectedEvents), true)
}

func TestFamilyIntroRequiresEmptyObject(t *testing.T) {
	f := setup(t)
	_, initial := f.call("GET", "/v1/snapshot", f.token, nil)
	for _, body := range []string{"", "null", "[]", `{"familyIntroSeen":false}`, `{} {}`} {
		req, err := http.NewRequest("POST", f.http.URL+familyIntroPath, bytes.NewBufferString(body))
		if err != nil {
			t.Fatal(err)
		}
		req.Header.Set("Authorization", "Bearer "+f.token)
		response, err := f.http.Client().Do(req)
		if err != nil {
			t.Fatal(err)
		}
		response.Body.Close()
		if response.StatusCode != 400 {
			t.Fatalf("body %q must be rejected: %d", body, response.StatusCode)
		}
	}
	_, after := f.call("GET", "/v1/snapshot", f.token, nil)
	assertFamilyIntro(t, after, false)
	if after["revision"] != initial["revision"] {
		t.Fatal("invalid requests changed state")
	}
}
