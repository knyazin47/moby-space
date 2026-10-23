package api

import (
	"context"
	"encoding/json"
	"strings"
)

func (s *Server) AppCreateChild(ctx context.Context, token string, in ChildInput) (Result[*Child], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[*Child]{}, domainError(499, "request_canceled")
	}
	if _, e := s.requireAdult(token); e != nil {
		return Result[*Child]{}, e
	}
	if in.IdempotencyKey != "" && (len(in.IdempotencyKey) < 8 || len(in.IdempotencyKey) > 80) {
		return Result[*Child]{}, domainError(400, "invalid_idempotency_key")
	}
	if !s.validChild(in) {
		return Result[*Child]{}, domainError(400, "invalid_child")
	}
	st := clone(s.state)
	raw, _ := json.Marshal(in)
	fingerprint := hash(string(raw))
	key := hash(st.AdultID + ":child-create:" + in.IdempotencyKey)
	if in.IdempotencyKey != "" {
		if command, exists := st.ChildCreates[key]; exists {
			if command.Fingerprint != fingerprint {
				return Result[*Child]{}, domainError(409, "idempotency_conflict")
			}
			return Result[*Child]{Value: st.Children[command.ChildID], Status: 200}, nil
		}
	}
	if len(st.Children) >= 100 {
		return Result[*Child]{}, domainError(409, "family_limit")
	}
	c := &Child{ID: id(), DisplayName: strings.TrimSpace(in.DisplayName), LegalName: in.LegalName, DateOfBirth: in.DateOfBirth, IdentityStatus: "draft", RepresentationStatus: "unverified", AgreementStatus: "not_signed", AccountStatus: "not_opened", CardStatus: "none", DeviceAccessStatus: "unpaired", MembershipStatus: "active", Currency: "BYN", Version: 1, Policy: Policy{Categories: defaultCategories(), Payments: true, Transfers: true, Internet: false, DailyLimit: 10000, MonthlyLimit: 40000, ApprovalThreshold: 5000}}
	st.Children[c.ID] = c
	if in.IdempotencyKey != "" {
		st.ChildCreates[key] = ChildCreateCommand{ChildID: c.ID, Fingerprint: fingerprint}
	}
	if s.save(st) != nil {
		return Result[*Child]{}, domainError(500, "storage_error")
	}
	return Result[*Child]{Value: c, Status: 201}, nil

}
func (s *Server) AppUpdateChild(ctx context.Context, token string, childID string, in ChildPatch) (Result[*Child], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[*Child]{}, domainError(499, "request_canceled")
	}
	st, c, e := s.mutableChild(token, childID)
	if e != nil {
		return Result[*Child]{}, e
	}
	if in.DisplayName != nil {
		c.DisplayName = strings.TrimSpace(*in.DisplayName)
	}
	if c.AgreementStatus == "synthetic_signed" && ((in.LegalName != nil && *in.LegalName != c.LegalName) || (in.DateOfBirth != nil && *in.DateOfBirth != c.DateOfBirth)) {
		return Result[*Child]{}, domainError(409, "signed_identity_locked")
	}
	if in.LegalName != nil && *in.LegalName != c.LegalName {
		c.LegalName = *in.LegalName
		c.IdentityStatus = "draft"
		c.RepresentationStatus = "unverified"
	}
	if in.DateOfBirth != nil && *in.DateOfBirth != c.DateOfBirth {
		c.DateOfBirth = *in.DateOfBirth
		c.IdentityStatus = "draft"
		c.RepresentationStatus = "unverified"
	}
	if in.CardStatus != nil {
		if *in.CardStatus != "none" && *in.CardStatus != "blocked" && *in.CardStatus != "active" {
			return Result[*Child]{}, domainError(400, "invalid_card_status")
		}
		if *in.CardStatus == "active" && (c.AccountStatus != "synthetic_open" || c.AgreementStatus != "synthetic_signed" || c.IdentityStatus != "verified") {
			return Result[*Child]{}, domainError(409, "product_unavailable")
		}
		c.CardStatus = *in.CardStatus
	}
	if !s.validChild(childInput{DisplayName: c.DisplayName, LegalName: c.LegalName, DateOfBirth: c.DateOfBirth}) {
		return Result[*Child]{}, domainError(400, "invalid_child")
	}
	return s.appCommitChild(st, c)

}
func (s *Server) AppPolicy(ctx context.Context, token string, childID string, in Policy) (Result[*Child], *DomainError) {
	p := in

	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[*Child]{}, domainError(499, "request_canceled")
	}
	st, c, e := s.mutableChild(token, childID)
	if e != nil {
		return Result[*Child]{}, e
	}
	if !validPolicy(p) {
		return Result[*Child]{}, domainError(400, "invalid_policy")
	}
	if p.Categories == nil {
		p.Categories = c.Policy.Categories
	}
	c.Policy = p
	return s.appCommitChild(st, c)

}
func (s *Server) AppArchive(ctx context.Context, token string, childID string) (Result[*Child], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[*Child]{}, domainError(499, "request_canceled")
	}
	st, c, e := s.mutableChild(token, childID)
	if e != nil {
		return Result[*Child]{}, e
	}
	if hasPendingFamilyObligations(st, c.ID) {
		return Result[*Child]{}, domainError(409, "pending_family_obligations")
	}
	c.MembershipStatus = "archived"
	c.DeviceAccessStatus = "revoked"
	for _, a := range st.Sessions {
		if a.ChildID == c.ID {
			a.Revoked = true
		}
	}
	for _, p := range st.Pairings {
		if p.ChildID == c.ID && p.Status == "approved" {
			p.Status = "cancelled"
		}
	}
	return s.appCommitChild(st, c)

}
func (s *Server) AppVerify(ctx context.Context, token string, childID string, in VerificationInput) (Result[*Child], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[*Child]{}, domainError(499, "request_canceled")
	}
	st, c, e := s.mutableChild(token, childID)
	if e != nil {
		return Result[*Child]{}, e
	}
	switch in.Outcome {
	case "verified", "needs_correction", "rejected", "pending":
	default:
		return Result[*Child]{}, domainError(400, "invalid_outcome")
	}
	if in.Outcome == "verified" && strings.TrimSpace(c.LegalName) == "" {
		return Result[*Child]{}, domainError(400, "legal_name_required")
	}
	c.IdentityStatus = in.Outcome
	if in.Outcome == "verified" {
		c.RepresentationStatus = "synthetic_verified"
	} else {
		c.RepresentationStatus = "unverified"
	}
	return s.appCommitChild(st, c)

}
