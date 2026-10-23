package api

import (
	"context"
	"encoding/json"
	"strings"
)

func (s *Server) AppProduct(ctx context.Context, token string, childID string, in ProductInput) (Result[*Child], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[*Child]{}, domainError(499, "request_canceled")
	}
	st, c, e := s.mutableChild(token, childID)
	if e != nil {
		return Result[*Child]{}, e
	}
	if in.AgreementVersion != "synthetic-v1" || !in.SignerConsent {
		return Result[*Child]{}, domainError(400, "synthetic_consent_required")
	}
	if c.IdentityStatus != "verified" || c.RepresentationStatus != "synthetic_verified" {
		return Result[*Child]{}, domainError(409, "verification_required")
	}
	if c.AgreementStatus == "synthetic_signed" {
		return Result[*Child]{Value: c, Status: 200}, nil
	}
	c.AgreementStatus = "synthetic_signed"
	c.AgreementVersion = in.AgreementVersion
	c.SignerID = st.AdultID
	c.SignedAt = s.cfg.Now().Unix()
	c.AccountStatus = "synthetic_open"
	c.CardStatus = "active"
	return s.appCommitChild(st, c)

}
func (s *Server) AppMoney(ctx context.Context, token string, childID string, in MoneyInput, topup bool) (Result[*Operation], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[*Operation]{}, domainError(499, "request_canceled")
	}
	a := s.sessionForToken(token)
	if a == nil {
		return Result[*Operation]{}, domainError(401, "unauthorized")
	}
	if (topup && a.Role != "adult") || (a.Role == "child" && a.ChildID != childID) {
		return Result[*Operation]{}, domainError(403, "forbidden")
	}
	if in.AmountMinor <= 0 || in.AmountMinor > 10000000 || in.Currency != "BYN" || len(in.IdempotencyKey) < 8 || len(in.IdempotencyKey) > 80 || len(in.Merchant) > 100 || (!topup && in.Channel != "pos" && in.Channel != "internet") {
		return Result[*Operation]{}, domainError(400, "invalid_money_command")
	}
	if in.Category == "" {
		in.Category = "other"
	}
	if !familyCategory(in.Category) {
		return Result[*Operation]{}, domainError(409, "category_prohibited")
	}
	st := clone(s.state)
	c := st.Children[childID]
	if c == nil {
		return Result[*Operation]{}, domainError(404, "not_found")
	}
	kind := "purchase"
	if topup {
		kind = "topup"
	}
	raw, _ := json.Marshal(in)
	fingerprint := hash(c.ID + kind + string(raw))
	actorID := s.state.AdultID
	if a.Role == "child" {
		actorID = a.ChildID
	}
	key := hash(actorID + ":" + in.IdempotencyKey)
	for _, o := range st.Operations {
		if o.RequestKey == key {
			if o.RequestHash != fingerprint {
				return Result[*Operation]{}, domainError(409, "idempotency_conflict")
			}
			return Result[*Operation]{Value: safeOperation(o), Status: 200}, nil
		}
	}
	if len(st.Operations) >= 10000 {
		return Result[*Operation]{}, domainError(409, "ledger_limit")
	}
	o := &Operation{ID: id(), ChildID: c.ID, Kind: kind, AmountMinor: in.AmountMinor, Currency: in.Currency, Channel: in.Channel, Category: in.Category, Merchant: strings.TrimSpace(in.Merchant), CreatedAt: s.cfg.Now().Unix(), Status: "done", Version: 1, RequestKey: key, RequestHash: fingerprint}
	if topup {
		if c.MembershipStatus != "active" || c.AccountStatus != "synthetic_open" || c.IdentityStatus != "verified" || c.AgreementStatus != "synthetic_signed" || c.BalanceMinor+in.AmountMinor > 100000000 {
			return Result[*Operation]{}, domainError(409, "topup_unavailable")
		}
		if st.FamilySpace.Wallet.AvailableMinor < in.AmountMinor {
			return Result[*Operation]{}, domainError(409, "insufficient_adult_balance")
		}
		st.FamilySpace.Wallet.AvailableMinor -= in.AmountMinor
		c.BalanceMinor += in.AmountMinor
	} else {
		if reason := s.purchaseGuard(st, c, o); reason != "" {
			return Result[*Operation]{}, domainError(409, reason)
		}
		if in.AmountMinor > c.Policy.ApprovalThreshold {
			o.Status = "pending"
		} else {
			c.BalanceMinor -= in.AmountMinor
		}
	}
	if o.Status == "done" {
		o.CompletedAt = s.cfg.Now().Unix()
	}
	st.Operations[o.ID] = o
	c.Version++
	if s.save(st) != nil {
		return Result[*Operation]{}, domainError(500, "storage_error")
	}
	return Result[*Operation]{Value: safeOperation(o), Status: 201}, nil

}
func (s *Server) AppDecision(ctx context.Context, token string, operationID string, in DecisionInput) (Result[*Operation], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[*Operation]{}, domainError(499, "request_canceled")
	}
	if _, e := s.requireAdult(token); e != nil {
		return Result[*Operation]{}, e
	}
	if in.Approve == nil {
		return Result[*Operation]{}, domainError(400, "decision_required")
	}
	st := clone(s.state)
	o := st.Operations[operationID]
	if o == nil {
		return Result[*Operation]{}, domainError(404, "not_found")
	}
	if o.Status != "pending" {
		if o.Decision != nil && *o.Decision == *in.Approve {
			return Result[*Operation]{Value: safeOperation(o), Status: 200}, nil
		}
		return Result[*Operation]{}, domainError(409, "operation_terminal")
	}
	c := st.Children[o.ChildID]
	if *in.Approve {
		if reason := s.purchaseGuard(st, c, o); reason != "" {
			return Result[*Operation]{}, domainError(409, reason)
		}
		c.BalanceMinor -= o.AmountMinor
		o.Status = "done"
		o.CompletedAt = s.cfg.Now().Unix()
	} else {
		o.Status = "declined"
	}
	o.Decision = in.Approve
	o.Version++
	c.Version++
	if s.save(st) != nil {
		return Result[*Operation]{}, domainError(500, "storage_error")
	}
	return Result[*Operation]{Value: safeOperation(o), Status: 200}, nil

}
