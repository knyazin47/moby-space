package api

import (
	"net/http"
	"strings"
	"time"
)

type childInput struct {
	DisplayName    string `json:"displayName"`
	LegalName      string `json:"legalName"`
	DateOfBirth    string `json:"dateOfBirth"`
	IdempotencyKey string `json:"idempotencyKey,omitempty"`
}

func (s *Server) validChild(in childInput) bool {
	date, _ := time.Parse("2006-01-02", s.cfg.BusinessDate)
	return len(strings.TrimSpace(in.DisplayName)) > 0 && len(in.DisplayName) <= 100 && len(in.LegalName) <= 200 && validDOB(in.DateOfBirth, date)
}
func (s *Server) createChild(w http.ResponseWriter, r *http.Request) {
	var in ChildInput
	if !decode(w, r, &in) {
		return
	}
	result, e := s.AppCreateChild(r.Context(), requestToken(r), in)
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) updateChild(w http.ResponseWriter, r *http.Request) {
	var in ChildPatch
	if !decode(w, r, &in) {
		return
	}
	result, e := s.AppUpdateChild(r.Context(), requestToken(r), r.PathValue("id"), in)
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) policy(w http.ResponseWriter, r *http.Request) {
	var in Policy
	if !decode(w, r, &in) {
		return
	}
	result, e := s.AppPolicy(r.Context(), requestToken(r), r.PathValue("id"), in)
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) archive(w http.ResponseWriter, r *http.Request) {
	result, e := s.AppArchive(r.Context(), requestToken(r), r.PathValue("id"))
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) verify(w http.ResponseWriter, r *http.Request) {
	var in VerificationInput
	if !decode(w, r, &in) {
		return
	}
	result, e := s.AppVerify(r.Context(), requestToken(r), r.PathValue("id"), in)
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) listSessions(w http.ResponseWriter, r *http.Request) {
	result, e := s.AppListSessions(r.Context(), requestToken(r))
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) revoke(w http.ResponseWriter, r *http.Request) {
	result, e := s.AppRevoke(r.Context(), requestToken(r), r.PathValue("id"))
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
