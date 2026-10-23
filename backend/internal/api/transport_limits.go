package api

import "errors"

// TransportLimits are operator-owned safety budgets, not end-user settings.
// Zero selects the bounded default; negative values are rejected at startup.
type TransportLimits struct {
	Pairings            int
	EventStreams        int
	SessionEventStreams int
	PeerEventStreams    int
}

func (limits TransportLimits) withDefaults() (TransportLimits, error) {
	fields := []struct {
		value    *int
		fallback int
	}{
		{&limits.Pairings, 1000},
		{&limits.EventStreams, 6},
		{&limits.SessionEventStreams, 2},
		{&limits.PeerEventStreams, 6},
	}
	for _, field := range fields {
		if *field.value < 0 {
			return TransportLimits{}, errors.New("transport limits must not be negative")
		}
		if *field.value == 0 {
			*field.value = field.fallback
		}
	}
	return limits, nil
}

// eventBudget is accessed only under Server.mu. It counts active handlers;
// rejected requests and disconnected handlers do not retain a lease.
type eventBudget struct {
	total    int
	sessions map[string]int
	peers    map[string]int
}

func (s *Server) acquireEvents(session, peer string) bool {
	limits := s.cfg.TransportLimits
	b := &s.eventsBudget
	if b.total >= limits.EventStreams || b.sessions[session] >= limits.SessionEventStreams || b.peers[peer] >= limits.PeerEventStreams {
		return false
	}
	if b.sessions == nil {
		b.sessions = make(map[string]int)
		b.peers = make(map[string]int)
	}
	b.total++
	b.sessions[session]++
	b.peers[peer]++
	return true
}

func (s *Server) releaseEvents(session, peer string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	b := &s.eventsBudget
	b.total--
	b.sessions[session]--
	b.peers[peer]--
	if b.sessions[session] == 0 {
		delete(b.sessions, session)
	}
	if b.peers[peer] == 0 {
		delete(b.peers, peer)
	}
}
