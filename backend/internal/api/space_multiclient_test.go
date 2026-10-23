package api

import (
	"bufio"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

// These tests use three independently authenticated HTTP/SSE clients. No domain
// method or direct state mutation supplies their money or expected revisions.
type v2ClientStream struct {
	response *http.Response
	reader   *bufio.Reader
	cancel   context.CancelFunc
}

func openV2ClientStream(t *testing.T, f *fixture, token string) *v2ClientStream {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	req, e := http.NewRequestWithContext(ctx, "GET", f.http.URL+"/v1/events", nil)
	if e != nil {
		cancel()
		t.Fatal(e)
	}
	req.Header.Set("Authorization", "Bearer "+token)
	res, e := f.http.Client().Do(req)
	if e != nil {
		cancel()
		t.Fatal(e)
	}
	if res.StatusCode != 200 {
		res.Body.Close()
		cancel()
		t.Fatalf("SSE status %d", res.StatusCode)
	}
	c := &v2ClientStream{response: res, reader: bufio.NewReader(res.Body), cancel: cancel}
	t.Cleanup(c.close)
	return c
}
func (c *v2ClientStream) close() { c.cancel(); c.response.Body.Close() }
func v2SiblingClients(t *testing.T, f *fixture) (string, string, string, string) {
	t.Helper()
	a, b := f.child("Live A"), f.child("Live B")
	ta, _ := f.pair(a)
	tb, _ := f.pair(b)
	for _, cid := range []string{a, b} {
		code, _ := f.call("POST", "/v1/children/"+cid+"/verification", f.token, map[string]string{"outcome": "verified"})
		if code != 200 {
			t.Fatal("verify sibling")
		}
		code, _ = f.call("POST", "/v1/children/"+cid+"/product", f.token, map[string]any{"agreementVersion": "synthetic-v1", "signerConsent": true})
		if code != 200 {
			t.Fatal("open sibling product")
		}
	}
	return a, b, ta, tb
}
func typedV2Snapshot(t *testing.T, v map[string]any) Snapshot {
	t.Helper()
	raw, e := json.Marshal(v)
	if e != nil {
		t.Fatal(e)
	}
	var snap Snapshot
	if e = json.Unmarshal(raw, &snap); e != nil {
		t.Fatal(e)
	}
	return snap
}
func assertV2ClientSnapshot(t *testing.T, v map[string]any, revision int64, scope, other string, available, reserved int64, balances map[string]int64) {
	t.Helper()
	snap := typedV2Snapshot(t, v)
	if snap.Revision != revision {
		t.Fatalf("scope %q revision got%d want%d", scope, snap.Revision, revision)
	}
	if scope == "" {
		if snap.Actor.Role != "adult" || len(snap.Children) != 2 || snap.FamilySpace.AdultWallet == nil {
			t.Fatal("adult stream lost family scope")
		}
		wallet := snap.FamilySpace.AdultWallet
		if wallet.AvailableMinor != available || wallet.ReservedMinor != reserved {
			t.Fatalf("adult wallet got%+v wantavailable%d reserved%d", wallet, available, reserved)
		}
		total := wallet.AvailableMinor + wallet.ReservedMinor
		for _, c := range snap.Children {
			if c.BalanceMinor != balances[c.ID] {
				t.Fatal("adult stream child balance mismatch")
			}
			total += c.BalanceMinor
		}
		for _, g := range snap.FamilySpace.Goals {
			total += g.SavedMinor
		}
		if total != 100000 {
			t.Fatalf("live buckets do not conserve endowment: %d", total)
		}
	} else {
		if snap.Actor.Role != "child" || snap.Actor.ChildID != scope || len(snap.Children) != 1 || snap.Children[0].ID != scope || snap.Children[0].BalanceMinor != balances[scope] {
			t.Fatal("child stream balance/identity mismatch")
		}
		if snap.FamilySpace.AdultWallet != nil || snap.Preferences != nil {
			t.Fatal("adult-only state leaked to child SSE")
		}
		raw, _ := json.Marshal(v)
		if strings.Contains(string(raw), other) {
			t.Fatal("sibling data leaked through v2 SSE")
		}
		if len(snap.FamilySpace.Settings) != 1 {
			t.Fatal("sibling preferences leaked")
		}
		for _, n := range snap.FamilySpace.Notices {
			if n.ChildID != scope || n.Recipient != "child" {
				t.Fatal("notice recipient leak")
			}
		}
	}
}
func readV2Clients(t *testing.T, adult, ca, cb *v2ClientStream, revision int64, a, b string, available, reserved int64, balances map[string]int64) {
	t.Helper()
	assertV2ClientSnapshot(t, event(t, adult.reader), revision, "", "", available, reserved, balances)
	assertV2ClientSnapshot(t, event(t, ca.reader), revision, a, b, available, reserved, balances)
	assertV2ClientSnapshot(t, event(t, cb.reader), revision, b, a, available, reserved, balances)
}

func TestSpaceThreeClientsHTTPCommandsSSEAndReconnect(t *testing.T) {
	f := setup(t)
	a, b, ta, tb := v2SiblingClients(t, f)
	pa, sa, sb := openV2ClientStream(t, f, f.token), openV2ClientStream(t, f, ta), openV2ClientStream(t, f, tb)
	_, initial := f.call("GET", "/v1/snapshot", f.token, nil)
	revision := typedV2Snapshot(t, initial).Revision
	balances := map[string]int64{a: 0, b: 0}
	readV2Clients(t, pa, sa, sb, revision, a, b, 100000, 0, balances)
	apply := func(token string, command SpaceCommand, available, reserved int64) map[string]any {
		t.Helper()
		v := spaceCall(t, f, token, command, 200)
		next := typedV2Snapshot(t, v).Revision
		if next != revision+1 {
			t.Fatal("HTTP command revision not committed once")
		}
		revision = next
		readV2Clients(t, pa, sa, sb, revision, a, b, available, reserved, balances)
		return v
	}
	balances[a] = 6000
	apply(f.token, SpaceCommand{Type: "wallet.transfer", ChildID: a, AmountMinor: 6000, IdempotencyKey: "live-transfer-a"}, 94000, 0)
	balances[b] = 4000
	apply(f.token, SpaceCommand{Type: "wallet.transfer", ChildID: b, AmountMinor: 4000, IdempotencyKey: "live-transfer-b"}, 90000, 0)
	v := apply(f.token, SpaceCommand{Type: "task.create", ChildID: a, Title: "Live task", RewardMinor: 500, IdempotencyKey: "live-task-create"}, 90000, 0)
	task := typedV2Snapshot(t, v).FamilySpace.Tasks[0].ID
	apply(ta, SpaceCommand{Type: "task.action", ChildID: a, EntityID: task, Action: "accept", IdempotencyKey: "live-task-accept"}, 89500, 500)
	apply(ta, SpaceCommand{Type: "task.action", ChildID: a, EntityID: task, Action: "submit", IdempotencyKey: "live-task-submit"}, 89500, 500)
	balances[a] = 6500
	apply(f.token, SpaceCommand{Type: "task.action", ChildID: a, EntityID: task, Action: "approve", IdempotencyKey: "live-task-approve"}, 89500, 0)
	v = apply(tb, SpaceCommand{Type: "goal.create", ChildID: b, Title: "Live goal", TargetMinor: 2000, IdempotencyKey: "live-goal-create"}, 89500, 0)
	goal := typedV2Snapshot(t, v).FamilySpace.Goals[0].ID
	balances[b] = 3000
	apply(tb, SpaceCommand{Type: "goal.move", ChildID: b, EntityID: goal, Action: "deposit", AmountMinor: 1000, IdempotencyKey: "live-goal-deposit"}, 89500, 0)
	balances[b] = 3250
	apply(tb, SpaceCommand{Type: "goal.move", ChildID: b, EntityID: goal, Action: "withdraw", AmountMinor: 250, IdempotencyKey: "live-goal-withdraw"}, 89500, 0)
	sb.close()
	reconnected := openV2ClientStream(t, f, tb)
	current := event(t, reconnected.reader)
	assertV2ClientSnapshot(t, current, revision, b, a, 89500, 0, balances)
	snap := typedV2Snapshot(t, current)
	if len(snap.FamilySpace.Goals) != 1 || snap.FamilySpace.Goals[0].SavedMinor != 750 || len(snap.FamilySpace.Tasks) != 0 {
		t.Fatal("reconnect lost goal or gained sibling task")
	}
}

func TestSpaceThreeClientsRestartKeepsHoldsGoalsAndCommandRetries(t *testing.T) {
	f := setup(t)
	a, b, ta, tb := v2SiblingClients(t, f)
	spaceCall(t, f, f.token, SpaceCommand{Type: "wallet.transfer", ChildID: a, AmountMinor: 5000, IdempotencyKey: "restart-transfer-a"}, 200)
	spaceCall(t, f, f.token, SpaceCommand{Type: "wallet.transfer", ChildID: b, AmountMinor: 3000, IdempotencyKey: "restart-transfer-b"}, 200)
	v := spaceCall(t, f, f.token, SpaceCommand{Type: "task.create", ChildID: a, Title: "Persistent hold", RewardMinor: 700, IdempotencyKey: "restart-task-create"}, 200)
	task := typedV2Snapshot(t, v).FamilySpace.Tasks[0].ID
	accept := SpaceCommand{Type: "task.action", ChildID: a, EntityID: task, Action: "accept", IdempotencyKey: "restart-task-accept"}
	spaceCall(t, f, ta, accept, 200)
	v = spaceCall(t, f, tb, SpaceCommand{Type: "goal.create", ChildID: b, Title: "Persistent goal", TargetMinor: 2000, IdempotencyKey: "restart-goal-create"}, 200)
	goal := typedV2Snapshot(t, v).FamilySpace.Goals[0].ID
	deposit := SpaceCommand{Type: "goal.move", ChildID: b, EntityID: goal, Action: "deposit", AmountMinor: 1200, IdempotencyKey: "restart-goal-deposit"}
	spaceCall(t, f, tb, deposit, 200)
	_, before := f.call("GET", "/v1/snapshot", f.token, nil)
	revision := typedV2Snapshot(t, before).Revision
	balances := map[string]int64{a: 5000, b: 1800}
	pa, sa, sb := openV2ClientStream(t, f, f.token), openV2ClientStream(t, f, ta), openV2ClientStream(t, f, tb)
	readV2Clients(t, pa, sa, sb, revision, a, b, 91300, 700, balances)
	// Close the three actual streams before stopping HTTP and reopening SQLite.
	pa.close()
	sa.close()
	sb.close()
	cfg := f.s.cfg
	f.http.Close()
	if e := f.s.Close(); e != nil {
		t.Fatal(e)
	}
	reopened, e := New(cfg)
	if e != nil {
		t.Fatal(e)
	}
	f.s = reopened
	f.http = httptest.NewServer(reopened)
	t.Cleanup(func() { f.http.Close(); reopened.Close() })
	_, after := f.call("GET", "/v1/snapshot", f.token, nil)
	beforeSpace, _ := json.Marshal(before["familySpace"])
	afterSpace, _ := json.Marshal(after["familySpace"])
	if string(beforeSpace) != string(afterSpace) {
		t.Fatal("restart changed persisted v2 family state")
	}
	pa, sa, sb = openV2ClientStream(t, f, f.token), openV2ClientStream(t, f, ta), openV2ClientStream(t, f, tb)
	readV2Clients(t, pa, sa, sb, revision, a, b, 91300, 700, balances)
	for _, retry := range []struct {
		token   string
		command SpaceCommand
	}{{ta, accept}, {tb, deposit}} {
		v = spaceCall(t, f, retry.token, retry.command, 200)
		if typedV2Snapshot(t, v).Revision != revision {
			t.Fatal("restart retry reserved or deposited twice")
		}
	}
	v = spaceCall(t, f, ta, SpaceCommand{Type: "task.action", ChildID: a, EntityID: task, Action: "submit", IdempotencyKey: "restart-task-submit"}, 200)
	revision = typedV2Snapshot(t, v).Revision
	readV2Clients(t, pa, sa, sb, revision, a, b, 91300, 700, balances)
	approve := SpaceCommand{Type: "task.action", ChildID: a, EntityID: task, Action: "approve", IdempotencyKey: "restart-task-approve"}
	v = spaceCall(t, f, f.token, approve, 200)
	revision = typedV2Snapshot(t, v).Revision
	balances[a] = 5700
	readV2Clients(t, pa, sa, sb, revision, a, b, 91300, 0, balances)
	v = spaceCall(t, f, f.token, approve, 200)
	if typedV2Snapshot(t, v).Revision != revision || typedV2Snapshot(t, v).FamilySpace.Tasks[0].Status != "approved" {
		t.Fatal("postrestart payout retry changed state")
	}
}
