package api

import "strings"

func workOpen(status string) bool {
	return status == "accepted" || status == "submitted" || status == "clarification" || status == "disputed"
}
func (s *Server) taskAction(st *State, c *Child, adult bool, in SpaceCommand) string {
	f := st.FamilySpace
	t := f.Tasks[in.EntityID]
	if t == nil || t.ChildID != c.ID {
		return "not_found"
	}
	switch in.Action {
	case "accept":
		if adult {
			return "forbidden"
		}
		if t.Status != "offered" {
			return "invalid_task_state"
		}
		if !settingsFor(f, c.ID).TasksEnabled {
			return "feature_disabled"
		}
		if !reserve(f, t.RewardMinor) {
			return "insufficient_adult_balance"
		}
		t.Status = "accepted"
	case "submit":
		if adult {
			return "forbidden"
		}
		if t.Status != "accepted" && t.Status != "clarification" && t.Status != "disputed" {
			return "invalid_task_state"
		}
		t.Status = "submitted"
	case "approve":
		if !adult {
			return "forbidden"
		}
		if t.Status != "submitted" {
			return "invalid_task_state"
		}
		if !credit(c, t.RewardMinor) {
			return "balance_limit"
		}
		f.Wallet.ReservedMinor -= t.RewardMinor
		t.Status = "approved"
		s.spaceEntry(st, c.ID, "task_reward", t.ID, t.RewardMinor)
		s.spaceEntry(st, c.ID, "task_complete", t.ID, 0)
	case "clarify":
		if !adult {
			return "forbidden"
		}
		if t.Status != "submitted" && t.Status != "disputed" {
			return "invalid_task_state"
		}
		t.Status = "clarification"
	case "dispute":
		if adult {
			return "forbidden"
		}
		if !workOpen(t.Status) {
			return "invalid_task_state"
		}
		t.Status = "disputed"
	case "cancel":
		if !adult {
			return "forbidden"
		}
		if t.Status != "offered" && !workOpen(t.Status) {
			return "invalid_task_state"
		}
		if len(strings.TrimSpace(in.Reason)) == 0 || len(in.Reason) > 240 {
			return "invalid_cancel_reason"
		}
		if workOpen(t.Status) {
			release(f, t.RewardMinor)
		}
		t.CancelReason = strings.TrimSpace(in.Reason)
		t.Status = "canceled"
	case "request_cancel":
		if !adult {
			return "forbidden"
		}
		if !workOpen(t.Status) {
			return "invalid_task_state"
		}
		t.CancelRequested = true
	case "agree_cancel":
		if adult {
			return "forbidden"
		}
		if !workOpen(t.Status) || !t.CancelRequested {
			return "invalid_task_state"
		}
		release(f, t.RewardMinor)
		t.Status = "canceled"
	default:
		return "invalid_action"
	}
	return ""
}
func (s *Server) errandAction(st *State, c *Child, adult bool, in SpaceCommand) string {
	f := st.FamilySpace
	e := f.Errands[in.EntityID]
	if e == nil || e.ChildID != c.ID {
		return "not_found"
	}
	switch in.Action {
	case "fund":
		if !adult {
			return "forbidden"
		}
		if e.Status != "offered" || e.Funding != "awaiting_funds" {
			return "invalid_errand_state"
		}
		if !reserve(f, e.BudgetMinor+e.RewardMinor) {
			return "insufficient_adult_balance"
		}
		e.Funding = "funded"
	case "accept":
		if adult {
			return "forbidden"
		}
		if e.Status != "offered" || e.Funding == "awaiting_funds" {
			return "invalid_errand_state"
		}
		if !settingsFor(f, c.ID).ErrandsEnabled {
			return "feature_disabled"
		}
		if e.Funding == "reimburse" {
			if !in.OwnMoneyConsent {
				return "own_money_consent_required"
			}
			if !reserve(f, e.RewardMinor) {
				return "insufficient_adult_balance"
			}
			e.RewardReserved = true
			e.OwnMoneyConsent = true
		}
		e.Status = "accepted"
	case "submit":
		if adult {
			return "forbidden"
		}
		if e.Status != "accepted" && e.Status != "clarification" && e.Status != "disputed" {
			return "invalid_errand_state"
		}
		if !boundedMoney(in.AmountMinor) || in.AmountMinor > e.BudgetMinor {
			return "invalid_actual_amount"
		}
		// A resubmission may clarify evidence but cannot change the already recorded expense.
		if e.ExpenseRecorded && in.AmountMinor != e.ActualMinor {
			return "expense_locked"
		}
		if !e.ExpenseRecorded && e.Funding == "reimburse" {
			if !e.OwnMoneyConsent || c.BalanceMinor < in.AmountMinor {
				return "insufficient_balance"
			}
			c.BalanceMinor -= in.AmountMinor
			s.spaceEntry(st, c.ID, "errand_own_spend", e.ID, in.AmountMinor)
		}
		if !e.ExpenseRecorded {
			e.ReturnConfirmed = false
			e.ReturnedMinor = 0
		}
		e.ExpenseRecorded = true
		e.ActualMinor = in.AmountMinor
		e.Status = "submitted"
	case "return":
		if adult {
			return "forbidden"
		}
		if (e.Status != "submitted" && e.Status != "clarification" && e.Status != "disputed") || e.Funding != "funded" {
			return "invalid_errand_state"
		}
		e.ReturnedMinor = e.BudgetMinor - e.ActualMinor
		e.ReturnConfirmed = true
	case "approve":
		if !adult {
			return "forbidden"
		}
		if e.Status != "submitted" {
			return "invalid_errand_state"
		}
		if e.Funding == "funded" {
			if e.ActualMinor < e.BudgetMinor && !e.ReturnConfirmed {
				return "child_return_required"
			}
			if !credit(c, e.RewardMinor) {
				return "balance_limit"
			}
			f.Wallet.ReservedMinor -= e.BudgetMinor + e.RewardMinor
			f.Wallet.AvailableMinor += e.BudgetMinor - e.ActualMinor
			s.spaceEntry(st, c.ID, "errand_budget_spend", e.ID, e.ActualMinor)
		} else {
			n := e.ActualMinor + e.RewardMinor
			if f.Wallet.AvailableMinor < e.ActualMinor {
				return "insufficient_adult_balance"
			}
			if !credit(c, n) {
				return "balance_limit"
			}
			f.Wallet.AvailableMinor -= e.ActualMinor
			f.Wallet.ReservedMinor -= e.RewardMinor
			e.RewardReserved = false
			s.spaceEntry(st, c.ID, "errand_reimbursement", e.ID, e.ActualMinor)
		}
		s.spaceEntry(st, c.ID, "errand_reward", e.ID, e.RewardMinor)
		e.Status = "approved"
	case "clarify":
		if !adult {
			return "forbidden"
		}
		if e.Status != "submitted" && e.Status != "disputed" {
			return "invalid_errand_state"
		}
		e.Status = "clarification"
	case "dispute":
		if adult {
			return "forbidden"
		}
		if !workOpen(e.Status) {
			return "invalid_errand_state"
		}
		e.Status = "disputed"
	case "cancel":
		if !adult {
			return "forbidden"
		}
		if e.Status != "offered" && !workOpen(e.Status) {
			return "invalid_errand_state"
		}
		if e.ActualMinor > 0 {
			return "expense_requires_settlement"
		}
		if len(strings.TrimSpace(in.Reason)) == 0 || len(in.Reason) > 240 {
			return "invalid_cancel_reason"
		}
		if e.Funding == "funded" {
			release(f, e.BudgetMinor+e.RewardMinor)
		} else if e.RewardReserved {
			release(f, e.RewardMinor)
			e.RewardReserved = false
		}
		e.CancelReason = strings.TrimSpace(in.Reason)
		e.Status = "canceled"
	case "request_cancel":
		if !adult {
			return "forbidden"
		}
		if !workOpen(e.Status) {
			return "invalid_errand_state"
		}
		e.CancelRequested = true
	case "agree_cancel":
		if adult {
			return "forbidden"
		}
		if !workOpen(e.Status) || !e.CancelRequested {
			return "invalid_errand_state"
		}
		// Once an expense exists, it must be settled; cancellation cannot erase reimbursement.
		if e.ActualMinor > 0 {
			return "expense_requires_settlement"
		}
		if e.Funding == "funded" {
			release(f, e.BudgetMinor+e.RewardMinor)
		} else if e.RewardReserved {
			release(f, e.RewardMinor)
			e.RewardReserved = false
		}
		e.Status = "canceled"
	default:
		return "invalid_action"
	}
	return ""
}
