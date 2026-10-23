package api

import (
	"context"
	"crypto/subtle"
)

func (s *Server) AppLogin(ctx context.Context, token string, in LoginInput) (Result[SessionGrant], *DomainError) {
	if len(in.DeviceName) > 80 {
		return Result[SessionGrant]{}, domainError(400, "invalid_device_name")
	}
	given, want := hash(in.BootstrapSecret), hash(s.cfg.BootstrapSecret)
	if subtle.ConstantTimeCompare([]byte(given), []byte(want)) != 1 {
		return Result[SessionGrant]{}, domainError(401, "unauthorized")
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[SessionGrant]{}, domainError(499, "request_canceled")
	}
	st := clone(s.state)
	a, t := s.newSession(&st, "adult", "", in.DeviceName)
	if s.save(st) != nil {
		return Result[SessionGrant]{}, domainError(500, "storage_error")
	}
	return Result[SessionGrant]{Value: s.sessionGrant(a, t), Status: 200}, nil

}
func (s *Server) AppLogout(ctx context.Context, token string) (Result[SuccessAck], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[SuccessAck]{}, domainError(499, "request_canceled")
	}
	a := s.sessionForToken(token)
	if a == nil {
		return Result[SuccessAck]{}, domainError(401, "unauthorized")
	}
	st := clone(s.state)
	st.Sessions[a.ID].Revoked = true
	s.refreshDeviceAccess(&st, a.ChildID)
	if s.save(st) != nil {
		return Result[SuccessAck]{}, domainError(500, "storage_error")
	}
	return Result[SuccessAck]{Value: SuccessAck{OK: true}, Status: 200}, nil

}
func (s *Server) AppGetSnapshot(ctx context.Context, token string) (Result[Snapshot], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[Snapshot]{}, domainError(499, "request_canceled")
	}
	a := s.sessionForToken(token)
	if a == nil {
		return Result[Snapshot]{}, domainError(401, "unauthorized")
	}
	return Result[Snapshot]{Value: s.snapshot(a), Status: 200}, nil

}
func (s *Server) AppListChildren(ctx context.Context, token string) (Result[[]*Child], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[[]*Child]{}, domainError(499, "request_canceled")
	}
	a := s.sessionForToken(token)
	if a == nil {
		return Result[[]*Child]{}, domainError(401, "unauthorized")
	}
	return Result[[]*Child]{Value: s.snapshot(a).Children, Status: 200}, nil

}
func (s *Server) AppGetChild(ctx context.Context, token string, childID string) (Result[*Child], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[*Child]{}, domainError(499, "request_canceled")
	}
	a := s.sessionForToken(token)
	if a == nil {
		return Result[*Child]{}, domainError(401, "unauthorized")
	}
	if a.Role != "adult" && a.ChildID != childID {
		return Result[*Child]{}, domainError(403, "forbidden")
	}
	c := s.state.Children[childID]
	if c == nil {
		return Result[*Child]{}, domainError(404, "not_found")
	}
	return Result[*Child]{Value: c, Status: 200}, nil

}
func (s *Server) AppListSessions(ctx context.Context, token string) (Result[[]SessionSummary], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[[]SessionSummary]{}, domainError(499, "request_canceled")
	}
	if _, e := s.requireAdult(token); e != nil {
		return Result[[]SessionSummary]{}, e
	}
	out := []SessionSummary{}
	for _, a := range s.state.Sessions {
		out = append(out, SessionSummary{ID: a.ID, Role: a.Role, ChildID: a.ChildID, DeviceName: a.DeviceName, ExpiresAt: a.ExpiresAt, Revoked: a.Revoked})
	}
	return Result[[]SessionSummary]{Value: out, Status: 200}, nil

}
func (s *Server) AppRevoke(ctx context.Context, token string, sessionID string) (Result[SuccessAck], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[SuccessAck]{}, domainError(499, "request_canceled")
	}
	if _, e := s.requireAdult(token); e != nil {
		return Result[SuccessAck]{}, e
	}
	st := clone(s.state)
	a := st.Sessions[sessionID]
	if a == nil {
		return Result[SuccessAck]{}, domainError(404, "not_found")
	}
	a.Revoked = true
	if a.ChildID != "" {
		active := false
		for _, other := range st.Sessions {
			if other.ChildID == a.ChildID && !other.Revoked && other.ExpiresAt > s.cfg.Now().Unix() {
				active = true
			}
		}
		if !active {
			st.Children[a.ChildID].DeviceAccessStatus = "revoked"
			st.Children[a.ChildID].Version++
		}
	}
	if s.save(st) != nil {
		return Result[SuccessAck]{}, domainError(500, "storage_error")
	}
	return Result[SuccessAck]{Value: SuccessAck{OK: true}, Status: 200}, nil

}
func (s *Server) AppCompleteFamilyIntro(ctx context.Context, token string) (Result[Snapshot], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[Snapshot]{}, domainError(499, "request_canceled")
	}
	a, e := s.requireAdult(token)
	if e != nil {
		return Result[Snapshot]{}, e
	}
	if !s.state.Preferences.FamilyIntroSeen {
		st := clone(s.state)
		st.Preferences.FamilyIntroSeen = true
		if s.save(st) != nil {
			return Result[Snapshot]{}, domainError(500, "storage_error")
		}
	}
	return Result[Snapshot]{Value: s.snapshot(a), Status: 200}, nil

}
