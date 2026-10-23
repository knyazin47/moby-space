package api

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestPairingCapacityRecoversAtExpiry(t *testing.T) {
	f := setup(t)
	f.s.mu.Lock()
	now := f.s.cfg.Now().Unix()
	for i := range 1000 {
		key := fmt.Sprintf("expired-%d", i)
		f.s.state.Pairings[key] = &Pairing{ID: key, ExpiresAt: now, Status: "waiting"}
	}
	f.s.mu.Unlock()
	result, err := f.s.AppCreatePair(context.Background(), "", CreatePairInput{DeviceName: "new phone"})
	if err != nil {
		t.Fatalf("expired pairings must not exhaust capacity: %v", err)
	}
	f.s.mu.Lock()
	defer f.s.mu.Unlock()
	if len(f.s.state.Pairings) != 1 || f.s.state.Pairings[result.Value.ID] == nil {
		t.Fatal("expired pairings were not reclaimed")
	}
}

func TestRESTEventStreamConcurrentBudgetsAndRelease(t *testing.T) {
	f := setup(t)
	var opened []*http.Response
	t.Cleanup(func() {
		for _, res := range opened {
			res.Body.Close()
		}
	})
	open := func(token string, want int) *http.Response {
		t.Helper()
		req, _ := http.NewRequest("GET", f.http.URL+"/v1/events", nil)
		req.Header.Set("Authorization", "Bearer "+token)
		res, err := f.http.Client().Do(req)
		if err != nil {
			t.Fatal(err)
		}
		opened = append(opened, res)
		if res.StatusCode != want {
			t.Fatalf("stream status: got %d want %d", res.StatusCode, want)
		}
		return res
	}
	open("invalid", 401).Body.Close()
	first := open(f.token, 200)
	open(f.token, 200)
	open(f.token, 429).Body.Close()
	first.Body.Close()
	// Cancellation must release capacity without waiting for the heartbeat.
	deadline := time.Now().Add(2 * time.Second)
	for {
		f.s.mu.Lock()
		remaining := f.s.eventsBudget.total
		f.s.mu.Unlock()
		if remaining == 1 {
			break
		}
		if time.Now().After(deadline) {
			t.Fatal("stream slot not released on disconnect")
		}
		time.Sleep(time.Millisecond)
	}
	open(f.token, 200)
	for i := range 2 {
		grant, err := f.s.AppLogin(context.Background(), "", LoginInput{BootstrapSecret: testSecret, DeviceName: fmt.Sprintf("adult-%d", i)})
		if err != nil {
			t.Fatal(err)
		}
		open(grant.Value.Token, 200)
		open(grant.Value.Token, 200)
	}
	grant, err := f.s.AppLogin(context.Background(), "", LoginInput{BootstrapSecret: testSecret})
	if err != nil {
		t.Fatal(err)
	}
	open(grant.Value.Token, 429).Body.Close()
}

func TestPairingLiveCapacityPreservesDeliveredRetry(t *testing.T) {
	f := setup(t)
	child := f.child("Child")
	f.s.mu.Lock()
	f.s.cfg.TransportLimits.Pairings = 1
	f.s.mu.Unlock()
	pair, err := f.s.AppCreatePair(context.Background(), "", CreatePairInput{})
	if err != nil {
		t.Fatal(err)
	}
	_, err = f.s.AppCreatePair(context.Background(), "", CreatePairInput{})
	if err == nil || err.Status != 429 || err.Code != "pairing_limit" {
		t.Fatalf("live pairing must retain its capacity: %v", err)
	}
	_, err = f.s.AppConsumePair(context.Background(), f.token, ConsumePairInput{Code: pair.Value.Code, ChildID: child})
	if err != nil {
		t.Fatal(err)
	}
	first, err := f.s.AppPollPair(context.Background(), "", pair.Value.ID, PairSecretInput{RequestSecret: pair.Value.RequestSecret})
	if err != nil {
		t.Fatal(err)
	}
	_, err = f.s.AppCreatePair(context.Background(), "", CreatePairInput{})
	if err == nil || err.Code != "pairing_limit" {
		t.Fatalf("live delivery recovery must retain its record: %v", err)
	}
	retried, err := f.s.AppPollPair(context.Background(), "", pair.Value.ID, PairSecretInput{RequestSecret: pair.Value.RequestSecret})
	if err != nil || first.Value.Session == nil || retried.Value.Session == nil || first.Value.Session.Token != retried.Value.Session.Token {
		t.Fatalf("lost delivery acknowledgement must recover the same session: %v", err)
	}
}

func TestRESTEventStreamPeerLimitIgnoresForwardedHeader(t *testing.T) {
	f := setup(t)
	f.s.mu.Lock()
	f.s.cfg.TransportLimits.PeerEventStreams = 1
	f.s.mu.Unlock()
	res, _ := stream(t, f, f.token)
	defer res.Body.Close()
	grant, err := f.s.AppLogin(context.Background(), "", LoginInput{BootstrapSecret: testSecret})
	if err != nil {
		t.Fatal(err)
	}
	req, _ := http.NewRequest("GET", f.http.URL+"/v1/events", nil)
	req.Header.Set("Authorization", "Bearer "+grant.Value.Token)
	req.Header.Set("X-Forwarded-For", "192.0.2.50")
	blocked, requestErr := f.http.Client().Do(req)
	if requestErr != nil {
		t.Fatal(requestErr)
	}
	defer blocked.Body.Close()
	if blocked.StatusCode != 429 {
		t.Fatalf("peer budget bypassed by another session/header: %d", blocked.StatusCode)
	}
}

type failingEventWriter struct{ header http.Header }

func (w failingEventWriter) Header() http.Header { return w.header }
func (failingEventWriter) WriteHeader(int)       {}
func (failingEventWriter) Flush()                {}
func (failingEventWriter) Write([]byte) (int, error) {
	return 0, errors.New("disconnected")
}

func TestRESTEventStreamReleasesBudgetOnWriteFailureAndLogout(t *testing.T) {
	f := setup(t)
	req := httptest.NewRequest("GET", "/v1/events", nil)
	req.Header.Set("Authorization", "Bearer "+f.token)
	f.s.ServeHTTP(failingEventWriter{header: make(http.Header)}, req)
	assertEmpty := func() {
		t.Helper()
		f.s.mu.Lock()
		defer f.s.mu.Unlock()
		b := f.s.eventsBudget
		if b.total != 0 || len(b.sessions) != 0 || len(b.peers) != 0 {
			t.Fatalf("event budget leaked: %+v", b)
		}
	}
	assertEmpty()
	res, _ := stream(t, f, f.token)
	defer res.Body.Close()
	_, err := f.s.AppLogout(context.Background(), f.token)
	if err != nil {
		t.Fatal(err)
	}
	done := make(chan struct{})
	go func() {
		_, _ = io.Copy(io.Discard, res.Body)
		close(done)
	}()
	select {
	case <-done:
	case <-time.After(2 * time.Second):
		t.Fatal("logout did not close event stream")
	}
	assertEmpty()
}
