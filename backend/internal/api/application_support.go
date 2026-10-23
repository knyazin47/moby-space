package api

import (
	"context"
	"crypto/subtle"
	"time"
)

func (s *Server) sessionForToken(raw string) *Session {
	if len(raw) != 64 {
		return nil
	}
	h := hash(raw)
	for _, v := range s.state.Sessions {
		if subtle.ConstantTimeCompare([]byte(h), []byte(v.TokenHash)) == 1 && !v.Revoked && v.ExpiresAt > s.cfg.Now().Unix() {
			if v.Role == "child" {
				c := s.state.Children[v.ChildID]
				if c == nil || c.MembershipStatus != "active" {
					return nil
				}
			}
			return v
		}
	}
	return nil
}
func (s *Server) requireAdult(token string) (*Session, *DomainError) {
	a := s.sessionForToken(token)
	if a == nil {
		return nil, domainError(401, "unauthorized")
	}
	if a.Role != "adult" {
		return nil, domainError(403, "forbidden")
	}
	return a, nil
}
func (s *Server) mutableChild(token, childID string) (State, *Child, *DomainError) {
	if _, e := s.requireAdult(token); e != nil {
		return State{}, nil, e
	}
	st := clone(s.state)
	c := st.Children[childID]
	if c == nil {
		return State{}, nil, domainError(404, "not_found")
	}
	if c.MembershipStatus != "active" {
		return State{}, nil, domainError(409, "membership_archived")
	}
	return st, c, nil
}
func (s *Server) appCommitChild(st State, c *Child) (Result[*Child], *DomainError) {
	c.Version++
	if s.save(st) != nil {
		return Result[*Child]{}, domainError(500, "storage_error")
	}
	return Result[*Child]{Value: c, Status: 200}, nil
}
func (s *Server) sessionGrant(a *Session, t string) SessionGrant {
	return SessionGrant{Token: t, Actor: s.actor(a), ExpiresAt: a.ExpiresAt}
}
func safeOperation(o *Operation) *Operation {
	cp := *o
	cp.RequestKey = ""
	cp.RequestHash = ""
	return &cp
}
func (s *Server) pairingBySecret(st State, pairingID, secret string) (*Pairing, *DomainError) {
	p := st.Pairings[pairingID]
	h := hash(secret)
	expected := hash("")
	if p != nil {
		expected = p.SecretHash
	}
	if subtle.ConstantTimeCompare([]byte(h), []byte(expected)) != 1 || p == nil {
		return nil, domainError(404, "pairing_not_found")
	}
	if p.ExpiresAt <= s.cfg.Now().Unix() {
		return nil, domainError(410, "pairing_expired")
	}
	return p, nil
}

// SubscribeSnapshot captures authentication, snapshot and its notification under
// one mutex. Slow readers never hold a transaction lock or a queued log.
func (s *Server) SubscribeSnapshot(ctx context.Context, token string) (Snapshot, <-chan struct{}, *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Snapshot{}, nil, domainError(499, "request_canceled")
	}
	a := s.sessionForToken(token)
	if a == nil {
		return Snapshot{}, nil, domainError(401, "unauthorized")
	}
	return s.snapshot(a), s.changed, nil
}
func (s *Server) Authorize(token string) *DomainError {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.sessionForToken(token) == nil {
		return domainError(401, "unauthorized")
	}
	return nil
}

// Forwarded headers never become an authority for transport rate limits.
func (s *Server) AllowTransportRequest(peer, class string, max int) bool {
	s.mu.Lock()
	defer s.mu.Unlock()
	now := s.cfg.Now()
	key := peer + ":" + class
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
		return false
	}
	s.limits[key] = b
	return b.count <= max
}
