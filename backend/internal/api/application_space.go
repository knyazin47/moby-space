package api

import (
	"bytes"
	"context"
	"encoding/json"
	"strings"
)

func (s *Server) AppSpaceCommand(ctx context.Context, token string, in SpaceCommand) (Result[Snapshot], *DomainError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if ctx.Err() != nil {
		return Result[Snapshot]{}, domainError(499, "request_canceled")
	}
	a := s.sessionForToken(token)
	if a == nil {
		return Result[Snapshot]{}, domainError(401, "unauthorized")
	}
	if a.Role == "child" && a.ChildID != in.ChildID {
		return Result[Snapshot]{}, domainError(403, "forbidden")
	}
	if !boundedMoney(in.AmountMinor) || !boundedMoney(in.BudgetMinor) || !boundedMoney(in.RewardMinor) || !boundedMoney(in.TargetMinor) {
		return Result[Snapshot]{}, domainError(400, "invalid_amount")
	}
	if len(in.IdempotencyKey) < 8 || len(in.IdempotencyKey) > 80 || len(in.Title) > 120 || len(strings.TrimSpace(in.Title)) == 0 && (strings.HasSuffix(in.Type, ".create")) {
		return Result[Snapshot]{}, domainError(400, "invalid_space_command")
	}
	st := clone(s.state)
	c := st.Children[in.ChildID]
	if c == nil {
		return Result[Snapshot]{}, domainError(404, "not_found")
	}
	if c.MembershipStatus != "active" && in.Type != "notice.read" {
		return Result[Snapshot]{}, domainError(409, "membership_archived")
	}
	actor := st.AdultID
	if a.Role == "child" {
		actor = a.ChildID
	}
	key := hash(actor + ":space:" + in.IdempotencyKey)
	raw, _ := json.Marshal(in)

	fingerprint := hash(string(raw))
	f := st.FamilySpace
	if old, ok := f.Commands[key]; ok {
		expected := fingerprint
		if old.FingerprintVersion == 0 {
			legacy := bytes.ReplaceAll(raw, []byte(`"categories":null,`), nil)
			legacy = bytes.ReplaceAll(legacy, []byte(`"categories":{},`), nil)
			expected = hash(string(legacy))
		}
		if old.Fingerprint != expected {
			return Result[Snapshot]{}, domainError(409, "idempotency_conflict")
		}
		return Result[Snapshot]{Value: s.snapshot(a), Status: 200}, nil
	}
	if len(f.Commands) >= 20000 || len(f.Entries) >= 50000 {
		return Result[Snapshot]{}, domainError(409, "space_limit")
	}
	moneyFeature := in.Type == "wallet.transfer" || strings.HasPrefix(in.Type, "goal.") || strings.HasPrefix(in.Type, "task.") || strings.HasPrefix(in.Type, "errand.") || strings.HasPrefix(in.Type, "allowance.")
	administrativeRelease := a.Role == "adult" && (in.Type == "task.action" && in.Action == "cancel" || in.Type == "errand.action" && in.Action == "cancel" || in.Type == "allowance.action" && in.Action == "pause")
	if moneyFeature && !administrativeRelease && (c.AccountStatus != "synthetic_open" || c.AgreementStatus != "synthetic_signed" || c.IdentityStatus != "verified") {
		return Result[Snapshot]{}, domainError(409, "product_unavailable")
	}
	code := s.applySpace(&st, c, a, in)
	if code != "" {
		status := 409
		if code == "forbidden" {
			status = 403
		}
		if code == "wrong_answer" || strings.HasPrefix(code, "invalid_") && !strings.HasSuffix(code, "_state") {
			status = 400
		}
		if code == "not_found" {
			status = 404
		}
		return Result[Snapshot]{}, domainError(status, code)
	}
	if in.Type != "notice.read" {
		s.commandNotice(&st, c, a, in)
	}
	f.Commands[key] = SpaceCommandRecord{Fingerprint: fingerprint, FingerprintVersion: 2}
	c.Version++
	if e := s.save(st); e != nil {
		return Result[Snapshot]{}, domainError(500, "storage_error")
	}
	return Result[Snapshot]{Value: s.snapshot(a), Status: 200}, nil

}
