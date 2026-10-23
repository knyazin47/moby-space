package api

import (
	"context"
	"errors"
	"strings"
	"time"
)

func dateString(t time.Time) string { return t.Format("2006-01-02") }
func parseFamilyDate(v string) (time.Time, error) {
	return time.ParseInLocation("2006-01-02", v, minskLocation)
}
func allowanceMatches(a *Allowance, d time.Time) bool {
	switch a.Frequency {
	case "daily":
		return true
	case "weekly":
		for _, w := range a.Weekdays {
			if int(d.Weekday()) == w {
				return true
			}
		}
	case "monthly":
		last := time.Date(d.Year(), d.Month()+1, 0, 0, 0, 0, 0, minskLocation).Day()
		day := a.MonthDay
		if day > last {
			day = last
		}
		return d.Day() == day
	}
	return false
}
func nextAllowanceDate(a *Allowance, from time.Time) string {
	for i := 0; i < 370; i++ {
		d := from.AddDate(0, 0, i)
		if allowanceMatches(a, d) {
			return dateString(d)
		}
	}
	return ""
}
func (s *Server) validatedAllowance(c *Child, in SpaceCommand) (*Allowance, string) {
	if strings.TrimSpace(in.Title) == "" || len(in.Title) > 120 {
		return nil, "invalid_allowance"
	}
	if !positiveMoney(in.AmountMinor) || in.RetryLimit < 0 || in.RetryLimit > 3 {
		return nil, "invalid_allowance"
	}
	d, e := parseFamilyDate(in.NextDate)
	if e != nil || d.Before(s.familyDate()) || d.After(s.familyDate().AddDate(2, 0, 0)) {
		return nil, "invalid_schedule_date"
	}
	if in.Frequency != "daily" && in.Frequency != "weekly" && in.Frequency != "monthly" {
		return nil, "invalid_frequency"
	}
	if in.Frequency == "monthly" && (in.MonthDay < 1 || in.MonthDay > 31) {
		return nil, "invalid_month_day"
	}
	if in.Frequency == "weekly" {
		if len(in.Weekdays) == 0 || len(in.Weekdays) > 7 {
			return nil, "invalid_weekdays"
		}
		seen := map[int]bool{}
		for _, w := range in.Weekdays {
			if w < 0 || w > 6 || seen[w] {
				return nil, "invalid_weekdays"
			}
			seen[w] = true
		}
	}

	a := &Allowance{ChildID: c.ID, Title: strings.TrimSpace(in.Title), AmountMinor: in.AmountMinor, Frequency: in.Frequency, Weekdays: append([]int{}, in.Weekdays...), MonthDay: in.MonthDay, RetryLimit: in.RetryLimit}
	a.NextDate = nextAllowanceDate(a, d)
	return a, ""
}
func (s *Server) createAllowance(st *State, c *Child, in SpaceCommand) string {
	a, code := s.validatedAllowance(c, in)
	if code != "" {
		return code
	}
	a.ID = id()
	a.Active = true
	st.FamilySpace.Allowances[a.ID] = a
	return ""
}
func (s *Server) updateAllowance(st *State, c *Child, in SpaceCommand) string {
	old := st.FamilySpace.Allowances[in.EntityID]
	if old == nil || old.ChildID != c.ID {
		return "not_found"
	}
	a, code := s.validatedAllowance(c, in)
	if code != "" {
		return code
	}
	a.ID = old.ID
	a.Active = old.Active
	st.FamilySpace.Allowances[a.ID] = a
	return ""
}
func (s *Server) allowanceAction(st *State, c *Child, in SpaceCommand) string {
	f := st.FamilySpace
	switch in.Action {
	case "pause", "resume":
		a := f.Allowances[in.EntityID]
		if a == nil || a.ChildID != c.ID {
			return "not_found"
		}
		a.Active = in.Action == "resume"
		if a.Active {
			d, _ := parseFamilyDate(a.NextDate)
			if d.Before(s.familyDate()) {
				a.NextDate = nextAllowanceDate(a, s.familyDate())
			}
		}
		return ""
	case "settle", "cancel":
		p := f.Installments[in.EntityID]
		if p == nil || p.ChildID != c.ID {
			return "not_found"
		}
		if p.Status != "insufficient" && p.Status != "missed" {
			return "installment_terminal"
		}
		if in.Action == "cancel" {
			p.Status = "canceled"
			return ""
		}
		if f.Wallet.AvailableMinor < p.AmountMinor {
			return "insufficient_adult_balance"
		}
		if !credit(c, p.AmountMinor) {
			return "balance_limit"
		}
		f.Wallet.AvailableMinor -= p.AmountMinor
		p.Status = "paid"
		p.Attempts++
		p.LastAttemptDate = dateString(s.familyDate())
		s.spaceEntry(st, c.ID, "allowance", p.ID, p.AmountMinor)
		return ""
	}
	return "invalid_action"
}

// RunDue is safe to call concurrently and after restarts. It never catches up missed periods.
// Every eligible batch either pays in full or marks every member insufficient, so map
// iteration and sibling IDs cannot become an implicit funding priority.
func (s *Server) RunDue() error {
	s.mu.Lock()
	defer s.mu.Unlock()
	st := clone(s.state)
	f := st.FamilySpace
	if f == nil {
		return nil
	}
	today := s.familyDate()
	todayKey := dateString(today)
	changed := false
	batch := []*Installment{}
	var total int64
	for _, a := range f.Allowances {
		c := st.Children[a.ChildID]
		if !a.Active || c == nil || c.MembershipStatus != "active" || c.AccountStatus != "synthetic_open" || c.AgreementStatus != "synthetic_signed" || c.IdentityStatus != "verified" {
			continue
		}
		due, e := parseFamilyDate(a.NextDate)
		if e != nil || due.After(today) {
			continue
		}

		missed := false
		// Persist every missed occurrence, but only today's occurrence may auto-pay.
		// A bounded pass resumes from its persisted cursor on the next tick.
		for count := 0; !due.After(today) && count < 3660; count++ {
			key := a.ID + ":" + dateString(due)
			if _, ok := f.Installments[key]; !ok {
				if len(f.Installments) >= 50000 {
					return errors.New("installment limit reached")
				}
				retryLimit := a.RetryLimit
				p := &Installment{RetryLimit: &retryLimit, ID: key, ChildID: c.ID, AllowanceID: a.ID, DueDate: dateString(due), AmountMinor: a.AmountMinor, Status: "pending"}
				f.Installments[key] = p
				if due.Before(today) {
					p.Status = "missed"
					missed = true
				} else {
					batch = append(batch, p)
					total += p.AmountMinor
				}
			}
			a.NextDate = nextAllowanceDate(a, due.AddDate(0, 0, 1))
			due, _ = parseFamilyDate(a.NextDate)
			changed = true
		}
		if missed {
			s.addNotice(&st, c.ID, "adult", "allowance.missed", "Пропущенные выплаты сохранены. Их можно выплатить вручную или отменить.", true)
		}

	}
	for _, p := range f.Installments {
		if p.Status != "insufficient" || p.LastAttemptDate == todayKey {
			continue
		}
		a := f.Allowances[p.AllowanceID]
		c := st.Children[p.ChildID]
		if a == nil || !a.Active || c == nil || c.MembershipStatus != "active" || c.AccountStatus != "synthetic_open" || c.AgreementStatus != "synthetic_signed" || c.IdentityStatus != "verified" {
			continue
		}
		last, _ := parseFamilyDate(p.LastAttemptDate)
		retryLimit := a.RetryLimit
		if p.RetryLimit != nil {
			retryLimit = *p.RetryLimit
		}
		if retryLimit > 0 && p.Attempts <= retryLimit && !last.After(today) {
			due, _ := parseFamilyDate(p.DueDate)
			if !today.After(due.AddDate(0, 0, retryLimit)) {
				batch = append(batch, p)
				total += p.AmountMinor
			}
		}
	}
	if len(batch) > 0 {
		changed = true
		canPay := f.Wallet.AvailableMinor >= total
		childTotals := map[string]int64{}
		for _, p := range batch {
			childTotals[p.ChildID] += p.AmountMinor
		}
		for cid, n := range childTotals {
			if st.Children[cid].BalanceMinor > moneyCap-n {
				canPay = false
			}
		}
		for _, p := range batch {
			p.Attempts++
			p.LastAttemptDate = todayKey
			p.Status = "insufficient"
			if !canPay {
				s.addNotice(&st, p.ChildID, "adult", "allowance.insufficient", "Недостаточно денег для всей группы выплат. Выберите выплаты для ручного решения.", true)
			}
			if canPay {
				c := st.Children[p.ChildID]
				c.BalanceMinor += p.AmountMinor
				c.Version++
				f.Wallet.AvailableMinor -= p.AmountMinor
				p.Status = "paid"
				s.spaceEntry(&st, c.ID, "allowance", p.ID, p.AmountMinor)
				s.addNotice(&st, c.ID, "child", "allowance.paid", "Выплата зачислена на доступный остаток.", true)
			}
		}
	}
	if changed {
		return s.save(st)
	}
	return nil
}
func (s *Server) RunScheduler(ctx context.Context) {
	tick := time.NewTicker(time.Minute)
	defer tick.Stop()
	_ = s.RunDue()
	for {
		select {
		case <-ctx.Done():
			return
		case <-tick.C:
			_ = s.RunDue()
		}
	}
}
