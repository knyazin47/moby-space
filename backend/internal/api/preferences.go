package api

import "net/http"

// completeFamilyIntro records an adult-owned preference independently of children
// and sessions. Retrying an already completed intro has no state side effects.
func (s *Server) completeFamilyIntro(w http.ResponseWriter, r *http.Request) {
	var in *struct{}
	if !decode(w, r, &in) {
		return
	}
	if in == nil {
		fail(w, 400, "invalid_body")
		return
	}
	result, e := s.AppCompleteFamilyIntro(r.Context(), requestToken(r))
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
