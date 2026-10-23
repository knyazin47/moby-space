package api

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	_ "modernc.org/sqlite"
	"net"
	"net/http"
	"sort"
	"strings"
	"sync"
	"time"
)

type Config struct {
	DatabasePath, BootstrapSecret, BusinessDate string
	PairTTL                                     time.Duration
	Now                                         func() time.Time
	TransportLimits                             TransportLimits
}
type bucket struct {
	at    time.Time
	count int
}
type Server struct {
	mu           sync.Mutex
	db           *sql.DB
	state        State
	cfg          Config
	changed      chan struct{}
	limits       map[string]bucket
	mux          *http.ServeMux
	eventsBudget eventBudget
}

func New(cfg Config) (*Server, error) {
	limits, err := cfg.TransportLimits.withDefaults()
	if err != nil {
		return nil, err
	}
	cfg.TransportLimits = limits
	if len(cfg.BootstrapSecret) < 32 {
		return nil, errors.New("bootstrap secret must contain at least 32 characters")
	}
	if cfg.Now == nil {
		cfg.Now = time.Now
	}
	if cfg.PairTTL == 0 {
		cfg.PairTTL = 2 * time.Minute
	}
	if cfg.BusinessDate == "" {
		cfg.BusinessDate = "2026-10-20"
	}
	if _, e := time.Parse("2006-01-02", cfg.BusinessDate); e != nil {
		return nil, errors.New("invalid business date")
	}
	db, e := sql.Open("sqlite", cfg.DatabasePath)
	if e != nil {
		return nil, e
	}
	db.SetMaxOpenConns(1)
	s := &Server{db: db, cfg: cfg, changed: make(chan struct{}), limits: map[string]bucket{}, mux: http.NewServeMux()}
	if _, e = db.Exec(`PRAGMA busy_timeout=5000; PRAGMA journal_mode=WAL; CREATE TABLE IF NOT EXISTS schema_migrations(version INTEGER PRIMARY KEY); CREATE TABLE IF NOT EXISTS family_state(id INTEGER PRIMARY KEY CHECK(id=1), document TEXT NOT NULL); INSERT OR IGNORE INTO schema_migrations(version) VALUES(1);`); e != nil {
		db.Close()
		return nil, e
	}
	var raw string
	e = db.QueryRow("SELECT document FROM family_state WHERE id=1").Scan(&raw)
	if e == sql.ErrNoRows {
		s.state = State{AdultID: id(), Children: map[string]*Child{}, Sessions: map[string]*Session{}, Pairings: map[string]*Pairing{}, Operations: map[string]*Operation{}}
		b, _ := json.Marshal(s.state)
		_, e = db.Exec("INSERT INTO family_state(id,document) VALUES(1,?)", string(b))
	} else if e == nil {
		e = json.Unmarshal([]byte(raw), &s.state)
	}
	if e != nil {
		db.Close()
		return nil, e
	}
	if s.state.Operations == nil {
		s.state.Operations = map[string]*Operation{}
	}
	if s.state.ChildCreates == nil {
		s.state.ChildCreates = map[string]ChildCreateCommand{}
	}
	if e = s.initializeSpace(); e != nil {
		db.Close()
		return nil, e
	}
	s.routes()
	return s, nil
}
func (s *Server) Close() error {
	s.mu.Lock()
	defer s.mu.Unlock()
	close(s.changed)
	s.changed = make(chan struct{})
	return s.db.Close()
}
func (s *Server) save(st State) error {
	if err := validateSpace(st); err != nil {
		return err
	}
	st.Revision++
	raw, e := json.Marshal(st)
	if e != nil {
		return e
	}
	tx, e := s.db.Begin()
	if e != nil {
		return e
	}
	defer tx.Rollback()
	if _, e = tx.Exec("UPDATE family_state SET document=? WHERE id=1", string(raw)); e != nil {
		return e
	}
	if e = tx.Commit(); e != nil {
		return e
	}
	s.state = st
	close(s.changed)
	s.changed = make(chan struct{})
	return nil
}
func (s *Server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Cache-Control", "no-store")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	// No wildcard CORS: native clients do not need it. Browser access is same-origin.
	r.Body = http.MaxBytesReader(w, r.Body, 8192)
	ip, _, _ := net.SplitHostPort(r.RemoteAddr)
	key := ip + ":" + strings.Split(strings.TrimPrefix(r.URL.Path, "/v1/"), "/")[0]
	max := 240
	if strings.HasPrefix(r.URL.Path, "/v1/pairings") {
		switch {
		case strings.HasSuffix(r.URL.Path, "/poll"):
			key = ip + ":pairing_poll"
		case strings.HasSuffix(r.URL.Path, "/cancel"):
			key = ip + ":pairing_cancel"
		case r.URL.Path == "/v1/pairings/consume":
			key = ip + ":pairing_consume"
		default:
			key = ip + ":pairing_create"
		}
	}
	if strings.HasPrefix(r.URL.Path, "/v1/auth/adult") {
		max = 12
	}
	if r.URL.Path == "/v1/pairings" || r.URL.Path == "/v1/pairings/consume" {
		max = 20
	}
	s.mu.Lock()
	now := s.cfg.Now()
	b := s.limits[key]
	if now.Sub(b.at) >= time.Minute {
		b = bucket{at: now}
	}
	b.count++
	if len(s.limits) >= 4096 {
		for k, v := range s.limits {
			if now.Sub(v.at) >= time.Minute {
				delete(s.limits, k)
			}
		}
	}
	if len(s.limits) >= 4096 && b.count == 1 {
		s.mu.Unlock()
		fail(w, 429, "rate_limited")
		return
	}
	s.limits[key] = b
	s.mu.Unlock()
	if b.count > max {
		fail(w, 429, "rate_limited")
		return
	}
	s.mux.ServeHTTP(w, r)
}
func decode(w http.ResponseWriter, r *http.Request, v any) bool {
	d := json.NewDecoder(r.Body)
	d.DisallowUnknownFields()
	if e := d.Decode(v); e != nil {
		fail(w, 400, "invalid_body")
		return false
	}
	var extra any
	if d.Decode(&extra) != io.EOF {
		fail(w, 400, "invalid_body")
		return false
	}
	return true
}
func write(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}
func fail(w http.ResponseWriter, status int, code string) {
	write(w, status, map[string]string{"error": code})
}
func (s *Server) auth(r *http.Request) *Session { return s.sessionForToken(requestToken(r)) }
func (s *Server) actor(a *Session) Actor {
	v := Actor{ID: s.state.AdultID, Role: a.Role, SessionID: a.ID, ChildID: a.ChildID}
	if a.Role == "child" {
		v.ID = a.ChildID
	}
	return v
}
func (s *Server) snapshot(a *Session) Snapshot {
	v := Snapshot{FamilySpace: s.spaceSnapshot(a), Revision: s.state.Revision, Actor: s.actor(a), Children: []*Child{}, Operations: []*Operation{}, Synthetic: true, BusinessDate: s.cfg.BusinessDate}
	if a.Role == "adult" {
		preferences := s.state.Preferences
		v.Preferences = &preferences
	}
	for _, c := range s.state.Children {
		if a.Role == "adult" || a.ChildID == c.ID {
			cp := *c
			if cp.DeviceAccessStatus == "paired" && !s.hasActiveChildSession(s.state, cp.ID) {
				cp.DeviceAccessStatus = "revoked"
			}
			v.Children = append(v.Children, &cp)
		}
	}
	for _, o := range s.state.Operations {
		if a.Role == "adult" || a.ChildID == o.ChildID {
			cp := *o
			cp.RequestHash = ""
			cp.RequestKey = ""
			v.Operations = append(v.Operations, &cp)
		}
	}
	sort.Slice(v.Operations, func(i, j int) bool {
		if v.Operations[i].CreatedAt == v.Operations[j].CreatedAt {
			return v.Operations[i].ID > v.Operations[j].ID
		}
		return v.Operations[i].CreatedAt > v.Operations[j].CreatedAt
	})
	sort.Slice(v.Children, func(i, j int) bool { return v.Children[i].ID < v.Children[j].ID })
	return v
}
func (s *Server) newSession(st *State, role, child, device string) (*Session, string) {
	token := randomToken()
	a := &Session{ID: id(), Role: role, ChildID: child, DeviceName: device, TokenHash: hash(token), ExpiresAt: s.cfg.Now().Add(7 * 24 * time.Hour).Unix()}
	st.Sessions[a.ID] = a
	return a, token
}
func (s *Server) routes() {
	s.mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) {
		write(w, 200, map[string]bool{"ok": true, "synthetic": true})
	})
	s.mux.HandleFunc("POST /v1/auth/adult", s.login)
	s.mux.HandleFunc("POST /v1/auth/logout", s.logout)
	s.mux.HandleFunc("GET /v1/snapshot", s.getSnapshot)
	s.mux.HandleFunc("POST /v1/family-space/commands", s.spaceCommand)
	s.mux.HandleFunc("POST /v1/preferences/family-intro/complete", s.completeFamilyIntro)
	s.mux.HandleFunc("GET /v1/children", s.listChildren)
	s.mux.HandleFunc("POST /v1/children", s.createChild)
	s.mux.HandleFunc("GET /v1/children/{id}", s.getChild)
	s.mux.HandleFunc("PATCH /v1/children/{id}", s.updateChild)
	s.mux.HandleFunc("PATCH /v1/children/{id}/policy", s.policy)
	s.mux.HandleFunc("POST /v1/children/{id}/archive", s.archive)
	s.mux.HandleFunc("POST /v1/children/{id}/verification", s.verify)
	s.mux.HandleFunc("POST /v1/children/{id}/product", s.product)
	s.mux.HandleFunc("POST /v1/children/{id}/operations", s.purchase)
	s.mux.HandleFunc("POST /v1/children/{id}/topups", s.topup)
	s.mux.HandleFunc("POST /v1/operations/{id}/decision", s.decision)
	s.mux.HandleFunc("POST /v1/pairings", s.createPair)
	s.mux.HandleFunc("POST /v1/pairings/consume", s.consumePair)
	s.mux.HandleFunc("POST /v1/pairings/{id}/poll", s.pollPair)
	s.mux.HandleFunc("POST /v1/pairings/{id}/cancel", s.cancelPair)
	s.mux.HandleFunc("GET /v1/sessions", s.listSessions)
	s.mux.HandleFunc("POST /v1/sessions/{id}/revoke", s.revoke)
	s.mux.HandleFunc("GET /v1/events", s.events)
}
func (s *Server) login(w http.ResponseWriter, r *http.Request) {
	var in LoginInput
	if !decode(w, r, &in) {
		return
	}
	result, e := s.AppLogin(r.Context(), requestToken(r), in)
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) logout(w http.ResponseWriter, r *http.Request) {
	result, e := s.AppLogout(r.Context(), requestToken(r))
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) getSnapshot(w http.ResponseWriter, r *http.Request) {
	result, e := s.AppGetSnapshot(r.Context(), requestToken(r))
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) listChildren(w http.ResponseWriter, r *http.Request) {
	result, e := s.AppListChildren(r.Context(), requestToken(r))
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) getChild(w http.ResponseWriter, r *http.Request) {
	result, e := s.AppGetChild(r.Context(), requestToken(r), r.PathValue("id"))
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) events(w http.ResponseWriter, r *http.Request) {
	f, ok := w.(http.Flusher)
	if !ok {
		fail(w, 500, "stream_unavailable")
		return
	}
	s.mu.Lock()
	a := s.auth(r)
	if a == nil {
		s.mu.Unlock()
		fail(w, 401, "unauthorized")
		return
	}
	peer, _, _ := net.SplitHostPort(r.RemoteAddr)
	if !s.acquireEvents(a.ID, peer) {
		s.mu.Unlock()
		fail(w, 429, "watch_limit")
		return
	}
	defer s.releaseEvents(a.ID, peer)
	snap := s.snapshot(a)
	changed := s.changed
	s.mu.Unlock()
	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("X-Accel-Buffering", "no")
	send := func(v Snapshot) bool {
		b, _ := json.Marshal(v)
		_ = http.NewResponseController(w).SetWriteDeadline(time.Now().Add(10 * time.Second))
		_, e := fmt.Fprintf(w, "id: %d\nevent: snapshot\ndata: %s\n\n", v.Revision, b)
		f.Flush()
		return e == nil
	}
	if !send(snap) {
		return
	}
	tick := time.NewTicker(10 * time.Second)
	defer tick.Stop()
	for {
		select {
		case <-r.Context().Done():
			return
		case <-changed:
		case <-tick.C:
		}
		s.mu.Lock()
		a = s.auth(r)
		if a == nil {
			s.mu.Unlock()
			return
		}
		snap = s.snapshot(a)
		changed = s.changed
		s.mu.Unlock()
		if !send(snap) {
			return
		}
	}
}

// Shutdown is available for embedders; the executable handles HTTP server lifecycle.
func (s *Server) Shutdown(_ context.Context) error { return s.Close() }

func (s *Server) refreshDeviceAccess(st *State, childID string) {
	if childID == "" {
		return
	}
	c := st.Children[childID]
	if c == nil {
		return
	}
	active := false
	for _, a := range st.Sessions {
		if a.ChildID == childID && !a.Revoked && a.ExpiresAt > s.cfg.Now().Unix() {
			active = true
		}
	}
	if active {
		c.DeviceAccessStatus = "paired"
	} else {
		c.DeviceAccessStatus = "revoked"
	}
	c.Version++
}

func (s *Server) hasActiveChildSession(st State, childID string) bool {
	for _, a := range st.Sessions {
		if a.ChildID == childID && !a.Revoked && a.ExpiresAt > s.cfg.Now().Unix() {
			return true
		}
	}
	return false
}
