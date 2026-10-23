package api

import (
	"context"
	"crypto/subtle"
	"strings"
)

func (s *Server) AppCreatePair(ctx context.Context, token string, in CreatePairInput) (Result[PairingCreated], *DomainError) {
	if len(in.DeviceName) > 80 {
		return Result[PairingCreated]{}, domainError(400, "invalid_device_name")
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[PairingCreated]{}, domainError(499, "request_canceled")
	}
	st := clone(s.state)
	now := s.cfg.Now().Unix()
	for k, p := range st.Pairings {
		// Polling and delivery recovery already end at ExpiresAt. Keeping those
		// unusable records for another hour only lets them exhaust the budget.
		if p.ExpiresAt <= now {
			delete(st.Pairings, k)
		}
	}
	if len(st.Pairings) >= s.cfg.TransportLimits.Pairings {
		return Result[PairingCreated]{}, domainError(429, "pairing_limit")
	}
	code := strings.ToUpper(randomToken()[:12])
	secret := randomToken()
	p := &Pairing{ID: id(), CodeHash: hash(code), SecretHash: hash(secret), DeviceName: in.DeviceName, ExpiresAt: s.cfg.Now().Add(s.cfg.PairTTL).Unix(), Status: "waiting"}
	st.Pairings[p.ID] = p
	if s.save(st) != nil {
		return Result[PairingCreated]{}, domainError(500, "storage_error")
	}
	return Result[PairingCreated]{Value: PairingCreated{ID: p.ID, Code: code, RequestSecret: secret, ExpiresAt: p.ExpiresAt, Status: p.Status}, Status: 201}, nil

}
func (s *Server) AppConsumePair(ctx context.Context, token string, in ConsumePairInput) (Result[PairingResult], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[PairingResult]{}, domainError(499, "request_canceled")
	}
	if _, e := s.requireAdult(token); e != nil {
		return Result[PairingResult]{}, e
	}
	st := clone(s.state)
	c := st.Children[in.ChildID]
	if c == nil || c.MembershipStatus != "active" {
		return Result[PairingResult]{}, domainError(404, "not_found")
	}
	var found *Pairing
	h := hash(strings.ToUpper(strings.TrimSpace(in.Code)))
	for _, p := range st.Pairings {
		if subtle.ConstantTimeCompare([]byte(h), []byte(p.CodeHash)) == 1 {
			found = p
		}
	}
	if found == nil {
		return Result[PairingResult]{}, domainError(404, "pairing_not_found")
	}
	if found.ExpiresAt <= s.cfg.Now().Unix() {
		return Result[PairingResult]{}, domainError(410, "pairing_expired")
	}
	if found.Status != "waiting" {
		return Result[PairingResult]{}, domainError(409, "pairing_used")
	}
	found.Status = "approved"
	found.ChildID = c.ID
	if s.save(st) != nil {
		return Result[PairingResult]{}, domainError(500, "storage_error")
	}
	return Result[PairingResult]{Value: PairingResult{ID: found.ID, Status: found.Status, ChildID: c.ID}, Status: 200}, nil

}
func (s *Server) AppPollPair(ctx context.Context, token string, pairingID string, in PairSecretInput) (Result[PairingPoll], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[PairingPoll]{}, domainError(499, "request_canceled")
	}
	st := clone(s.state)
	p, e := s.pairingBySecret(st, pairingID, in.RequestSecret)
	if e != nil {
		return Result[PairingPoll]{}, e
	}
	out := PairingPoll{Status: p.Status}
	if p.Status == "approved" {
		c := st.Children[p.ChildID]
		if c == nil || c.MembershipStatus != "active" {
			return Result[PairingPoll]{}, domainError(409, "membership_archived")
		}
		a, _ := s.newSession(&st, "child", c.ID, p.DeviceName)
		p.DeliverySalt = randomToken()
		p.SessionID = a.ID
		t := deliveryToken(in.RequestSecret, p)
		a.TokenHash = hash(t)
		p.Status = "delivered"
		c.DeviceAccessStatus = "paired"
		c.Version++
		if s.save(st) != nil {
			return Result[PairingPoll]{}, domainError(500, "storage_error")
		}
		out.Status = "delivered"
		grant := s.sessionGrant(a, t)
		out.Session = &grant
	}
	if p.Status == "delivered" {
		a := st.Sessions[p.SessionID]
		if a == nil || a.Revoked || a.ExpiresAt <= s.cfg.Now().Unix() {
			return Result[PairingPoll]{}, domainError(409, "session_revoked")
		}
		c := st.Children[a.ChildID]
		if c == nil || c.MembershipStatus != "active" {
			return Result[PairingPoll]{}, domainError(409, "membership_archived")
		}
		grant := s.sessionGrant(a, deliveryToken(in.RequestSecret, p))
		out.Session = &grant
	}
	return Result[PairingPoll]{Value: out, Status: 200}, nil

}
func (s *Server) AppCancelPair(ctx context.Context, token string, pairingID string, in PairSecretInput) (Result[PairingResult], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[PairingResult]{}, domainError(499, "request_canceled")
	}
	st := clone(s.state)
	p, e := s.pairingBySecret(st, pairingID, in.RequestSecret)
	if e != nil {
		return Result[PairingResult]{}, e
	}
	if p.Status != "waiting" && p.Status != "approved" {
		return Result[PairingResult]{}, domainError(409, "pairing_used")
	}
	p.Status = "cancelled"
	if s.save(st) != nil {
		return Result[PairingResult]{}, domainError(500, "storage_error")
	}
	return Result[PairingResult]{Value: PairingResult{Status: "cancelled"}, Status: 200}, nil

}
