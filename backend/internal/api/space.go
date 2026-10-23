package api

import (
	"errors"
	"net/http"
	"sort"
	"strings"
	"time"
	_ "time/tzdata"
)

var minskLocation = func() *time.Location {
	l, e := time.LoadLocation("Europe/Minsk")
	if e != nil {
		panic(e)
	}
	return l
}()

func (s *Server) familyDate() time.Time {
	n := s.cfg.Now().In(minskLocation)
	return time.Date(n.Year(), n.Month(), n.Day(), 0, 0, 0, 0, minskLocation)
}
func (s *Server) initializeSpace() error {

	if s.state.FamilySpace != nil {
		st := clone(s.state)
		changed := false
		if st.FamilySpace.Notices == nil {
			st.FamilySpace.Notices = map[string]*SpaceNotice{}
			changed = true
		}
		for _, p := range st.FamilySpace.Installments {
			if p.RetryLimit == nil {
				retry := 0
				if a := st.FamilySpace.Allowances[p.AllowanceID]; a != nil {
					retry = a.RetryLimit
				}
				p.RetryLimit = &retry
				changed = true
			}
		}
		// NetDepositsMinor is a nonnegative display value. Eligibility instead uses
		// saved minus all lifetime matching, retaining the signed withdrawal debt.
		for _, g := range st.FamilySpace.Goals {
			derived := max(int64(0), g.SavedMinor-g.MatchedMinor)
			if g.NetDepositsMinor != derived {
				g.NetDepositsMinor = derived
				changed = true
			}
		}
		if changed {
			return s.save(st)
		}
		return nil
	}

	st := clone(s.state)
	st.FamilySpace = &FamilySpaceState{Notices: map[string]*SpaceNotice{}, Wallet: Wallet{AvailableMinor: DefaultDemoMoney.InitialAdultMinor, Currency: "BYN"}, BootstrapRecorded: true, Goals: map[string]*Goal{}, Tasks: map[string]*FamilyTask{}, Errands: map[string]*Errand{}, Allowances: map[string]*Allowance{}, Installments: map[string]*Installment{}, Requests: map[string]*FamilyRequest{}, Settings: map[string]SpaceSettings{}, Learning: map[string]LessonCompletion{}, Commands: map[string]SpaceCommandRecord{}, Entries: []SpaceEntry{{ID: id(), Kind: "demo_opening_endowment", AmountMinor: DefaultDemoMoney.InitialAdultMinor, At: s.cfg.Now().Unix()}}}
	return s.save(st)
}
func (s *Server) spaceEntry(st *State, c, kind, entity string, amount int64) {
	st.FamilySpace.Entries = append(st.FamilySpace.Entries, SpaceEntry{ID: id(), ChildID: c, Kind: kind, EntityID: entity, AmountMinor: amount, At: s.cfg.Now().Unix()})
}
func positiveMoney(n int64) bool { return n > 0 && n <= 10000000 }
func boundedMoney(n int64) bool  { return n >= 0 && n <= 10000000 }
func reserve(f *FamilySpaceState, n int64) bool {
	if n < 0 || f.Wallet.AvailableMinor < n {
		return false
	}
	f.Wallet.AvailableMinor -= n
	f.Wallet.ReservedMinor += n
	return true
}
func release(f *FamilySpaceState, n int64) { f.Wallet.ReservedMinor -= n; f.Wallet.AvailableMinor += n }
func credit(c *Child, n int64) bool {
	if n < 0 || c.BalanceMinor > moneyCap-n {
		return false
	}
	c.BalanceMinor += n
	return true
}
func settingsFor(f *FamilySpaceState, c string) SpaceSettings {
	if v, ok := f.Settings[c]; ok {
		return v
	}
	return defaultSpaceSettings()
}
func (s *Server) spaceSnapshot(a *Session) FamilySpaceSnapshot {
	f := s.state.FamilySpace
	v := FamilySpaceSnapshot{Activity: []SpaceEntry{}, Notices: []*SpaceNotice{}, Capabilities: FamilyCapabilities{Synthetic: true, Currency: "BYN", TimeZone: "Europe/Minsk", MaxAmountMinor: 10000000, MatchingCapPeriod: "goal_lifetime", LessonsGrantPermissions: false}, Goals: []*Goal{}, Tasks: []*FamilyTask{}, Errands: []*Errand{}, Allowances: []*Allowance{}, Installments: []*Installment{}, Requests: []*FamilyRequest{}, Settings: map[string]SpaceSettings{}, Learning: []LessonCompletion{}, Lessons: lessonCatalogue, Weekly: []WeeklyOverview{}}
	if f == nil {
		return v
	}
	visible := func(c string) bool { return a.Role == "adult" || a.ChildID == c }
	for _, e := range f.Entries {
		if a.Role == "adult" || e.ChildID == a.ChildID {
			v.Activity = append(v.Activity, e)
		}
	}
	sort.Slice(v.Activity, func(i, j int) bool {
		if v.Activity[i].At == v.Activity[j].At {
			return v.Activity[i].ID > v.Activity[j].ID
		}
		return v.Activity[i].At > v.Activity[j].At
	})
	if len(v.Activity) > 200 {
		v.Activity = v.Activity[:200]
	}

	for _, n := range f.Notices {
		if n.Recipient == a.Role && visible(n.ChildID) {
			cp := *n
			v.Notices = append(v.Notices, &cp)
		}
	}
	sort.Slice(v.Notices, func(i, j int) bool {
		if v.Notices[i].CreatedAt == v.Notices[j].CreatedAt {
			return v.Notices[i].ID > v.Notices[j].ID
		}
		return v.Notices[i].CreatedAt > v.Notices[j].CreatedAt
	})
	if a.Role == "adult" {
		w := f.Wallet
		v.AdultWallet = &w
	}
	for _, g := range f.Goals {
		if visible(g.ChildID) {
			cp := *g
			cp.MatchingAvailableMinor = matchAvailable(g, settingsFor(f, g.ChildID))
			cp.MatchingStatus = "available"
			if cp.MatchingAvailableMinor == 0 {
				cp.MatchingStatus = "not_eligible"
			} else if f.Wallet.AvailableMinor < cp.MatchingAvailableMinor {
				cp.MatchingStatus = "awaiting_funds"
			}
			v.Goals = append(v.Goals, &cp)
		}
	}
	for _, g := range f.Tasks {
		if visible(g.ChildID) {
			v.Tasks = append(v.Tasks, g)
		}
	}
	for _, g := range f.Errands {
		if visible(g.ChildID) {
			v.Errands = append(v.Errands, g)
		}
	}
	for _, g := range f.Allowances {
		if visible(g.ChildID) {
			v.Allowances = append(v.Allowances, g)
		}
	}
	for _, g := range f.Installments {
		if visible(g.ChildID) {
			v.Installments = append(v.Installments, g)
		}
	}
	for _, g := range f.Requests {
		if visible(g.ChildID) {
			v.Requests = append(v.Requests, g)
		}
	}
	for _, g := range f.Learning {
		if visible(g.ChildID) {
			v.Learning = append(v.Learning, g)
		}
	}
	since := s.familyDate().AddDate(0, 0, -6)
	for cid := range s.state.Children {
		if !visible(cid) {
			continue
		}
		v.Settings[cid] = settingsFor(f, cid)
		week := WeeklyOverview{ChildID: cid, Since: since.Format("2006-01-02")}
		for _, o := range s.state.Operations {
			if o.ChildID == cid && o.Status == "done" && o.CompletedAt >= since.Unix() {
				if o.Kind == "purchase" {
					week.SpentMinor += o.AmountMinor
				} else if o.Kind == "topup" {
					week.IncomingMinor += o.AmountMinor
				}
			}
		}
		for _, e := range f.Entries {
			if e.ChildID != cid || e.At < since.Unix() {
				continue
			}
			switch e.Kind {
			case "task_reward", "errand_reward", "allowance", "goal_match":
				week.IncomingMinor += e.AmountMinor
			case "goal_deposit":
				week.SavedMinor += e.AmountMinor
			case "goal_withdraw":
				week.SavedMinor -= e.AmountMinor
			case "errand_own_spend", "errand_budget_spend":
				week.SpentMinor += e.AmountMinor
			case "task_complete":
				week.TasksCompleted++
			}
		}
		for _, l := range f.Learning {
			if l.ChildID == cid && l.CompletedAt >= since.Unix() {
				week.LessonsCompleted++
			}
		}
		v.Weekly = append(v.Weekly, week)
	}
	sort.Slice(v.Goals, func(i, j int) bool { return v.Goals[i].ID < v.Goals[j].ID })
	sort.Slice(v.Tasks, func(i, j int) bool { return v.Tasks[i].ID < v.Tasks[j].ID })
	sort.Slice(v.Errands, func(i, j int) bool { return v.Errands[i].ID < v.Errands[j].ID })
	sort.Slice(v.Allowances, func(i, j int) bool { return v.Allowances[i].ID < v.Allowances[j].ID })
	sort.Slice(v.Installments, func(i, j int) bool { return v.Installments[i].ID < v.Installments[j].ID })
	sort.Slice(v.Requests, func(i, j int) bool { return v.Requests[i].ID < v.Requests[j].ID })
	sort.Slice(v.Weekly, func(i, j int) bool { return v.Weekly[i].ChildID < v.Weekly[j].ChildID })
	sort.Slice(v.Learning, func(i, j int) bool {
		return v.Learning[i].ChildID+v.Learning[i].LessonID < v.Learning[j].ChildID+v.Learning[j].LessonID
	})
	return v
}
func (s *Server) spaceCommand(w http.ResponseWriter, r *http.Request) {
	var in SpaceCommand
	if !decode(w, r, &in) {
		return
	}
	result, e := s.AppSpaceCommand(r.Context(), requestToken(r), in)
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) applySpace(st *State, c *Child, a *Session, in SpaceCommand) string {
	f := st.FamilySpace
	adult := a.Role == "adult"
	settings := settingsFor(f, c.ID)
	switch in.Type {
	case "card.block":
		if c.AccountStatus != "synthetic_open" || (c.CardStatus != "active" && c.CardStatus != "blocked") {
			return "product_unavailable"
		}
		c.CardStatus = "blocked"
	case "notice.read":
		n := f.Notices[in.EntityID]
		if n == nil || n.ChildID != c.ID {
			return "not_found"
		}
		if n.Recipient != a.Role {
			return "forbidden"
		}
		n.Read = true
	case "wallet.transfer":
		if !adult {
			return "forbidden"
		}
		return s.spaceTransfer(st, c, in.AmountMinor)
	case "goal.create":
		if adult {
			return "forbidden"
		}
		if !positiveMoney(in.TargetMinor) {
			return "invalid_goal"
		}
		g := &Goal{ID: id(), ChildID: c.ID, Title: strings.TrimSpace(in.Title), TargetMinor: in.TargetMinor}
		f.Goals[g.ID] = g
	case "goal.move":
		if adult {
			return "forbidden"
		}
		g := f.Goals[in.EntityID]
		if g == nil || g.ChildID != c.ID {
			return "not_found"
		}
		if !positiveMoney(in.AmountMinor) {
			return "invalid_amount"
		}
		switch in.Action {
		case "deposit":
			if c.BalanceMinor < in.AmountMinor {
				return "insufficient_balance"
			}
			if g.SavedMinor > moneyCap-in.AmountMinor {
				return "invalid_amount"
			}
			c.BalanceMinor -= in.AmountMinor
			g.SavedMinor += in.AmountMinor
			g.NetDepositsMinor = max(int64(0), g.SavedMinor-g.MatchedMinor)
			s.spaceEntry(st, c.ID, "goal_deposit", g.ID, in.AmountMinor)
		case "withdraw":
			if g.SavedMinor < in.AmountMinor || !credit(c, in.AmountMinor) {
				return "insufficient_goal_balance"
			}
			g.SavedMinor -= in.AmountMinor
			g.NetDepositsMinor = max(int64(0), g.SavedMinor-g.MatchedMinor)
			s.spaceEntry(st, c.ID, "goal_withdraw", g.ID, in.AmountMinor)
		default:
			return "invalid_action"
		}
	case "goal.match":
		if !adult {
			return "forbidden"
		}
		g := f.Goals[in.EntityID]
		if g == nil || g.ChildID != c.ID {
			return "not_found"
		}
		if !positiveMoney(in.AmountMinor) || in.AmountMinor > matchAvailable(g, settings) {
			return "matching_limit"
		}
		if f.Wallet.AvailableMinor < in.AmountMinor || g.SavedMinor > moneyCap-in.AmountMinor {
			return "insufficient_balance"
		}
		f.Wallet.AvailableMinor -= in.AmountMinor
		g.SavedMinor += in.AmountMinor
		g.MatchedMinor += in.AmountMinor
		g.MatchedBasisMinor += (in.AmountMinor*100 + settings.MatchingPercent - 1) / settings.MatchingPercent
		s.spaceEntry(st, c.ID, "goal_match", g.ID, in.AmountMinor)
	case "task.create":
		if !adult {
			return "forbidden"
		}
		if !settings.TasksEnabled {
			return "feature_disabled"
		}
		if !positiveMoney(in.RewardMinor) {
			return "invalid_reward"
		}
		t := &FamilyTask{ID: id(), ChildID: c.ID, Title: strings.TrimSpace(in.Title), RewardMinor: in.RewardMinor, Status: "offered"}
		f.Tasks[t.ID] = t
	case "task.action":
		return s.taskAction(st, c, adult, in)
	case "errand.create":
		if !adult {
			return "forbidden"
		}
		if !settings.ErrandsEnabled {
			return "feature_disabled"
		}
		if !positiveMoney(in.BudgetMinor) || !boundedMoney(in.RewardMinor) || (in.Funding != "funded" && in.Funding != "reimburse" && in.Funding != "awaiting_funds") {
			return "invalid_errand"
		}
		e := &Errand{ID: id(), ChildID: c.ID, Title: strings.TrimSpace(in.Title), BudgetMinor: in.BudgetMinor, RewardMinor: in.RewardMinor, Funding: in.Funding, Status: "offered"}
		if in.Funding == "funded" && !reserve(f, in.BudgetMinor+in.RewardMinor) {
			return "insufficient_adult_balance"
		}
		f.Errands[e.ID] = e
	case "errand.action":
		return s.errandAction(st, c, adult, in)
	case "allowance.create":
		if !adult {
			return "forbidden"
		}
		return s.createAllowance(st, c, in)
	case "allowance.update":
		if !adult {
			return "forbidden"
		}
		return s.updateAllowance(st, c, in)
	case "allowance.action":
		if !adult {
			return "forbidden"
		}
		return s.allowanceAction(st, c, in)
	case "settings.update":
		if !adult {
			return "forbidden"
		}
		v := in.Settings
		if v == nil || v.MatchingPercent < 0 || v.MatchingPercent > 100 || !boundedMoney(v.MatchingCapMinor) {
			return "invalid_settings"
		}
		if !settings.MatchingEnabled && v.MatchingEnabled {
			for _, g := range f.Goals {
				if g.ChildID == c.ID && g.NetDepositsMinor > g.MatchedBasisMinor {
					g.MatchedBasisMinor = g.NetDepositsMinor
				}
			}
		}
		f.Settings[c.ID] = *v
	case "request.create":
		if adult {
			return "forbidden"
		}
		if in.Kind != "policy" && in.Kind != "help" && in.Kind != "money" {
			return "invalid_request"
		}
		if in.Kind == "policy" && (in.Policy == nil || !validPolicy(*in.Policy)) {
			return "invalid_policy"
		}
		if in.Kind == "money" && !positiveMoney(in.AmountMinor) {
			return "invalid_amount"
		}
		q := &FamilyRequest{AmountMinor: in.AmountMinor, ID: id(), ChildID: c.ID, Title: strings.TrimSpace(in.Title), Kind: in.Kind, Status: "pending"}
		if in.Kind == "policy" {
			if in.Policy.Categories == nil {
				in.Policy.Categories = c.Policy.Categories
			}
			q.Policy = in.Policy
		}
		f.Requests[q.ID] = q
	case "request.decide":
		if !adult {
			return "forbidden"
		}
		q := f.Requests[in.EntityID]
		if q == nil || q.ChildID != c.ID {
			return "not_found"
		}
		if q.Status != "pending" {
			return "request_terminal"
		}
		if in.Approve == nil {
			return "invalid_decision"
		}
		q.Status = "declined"
		if *in.Approve {
			if q.Kind == "money" {
				if code := s.spaceTransfer(st, c, q.AmountMinor); code != "" {
					return code
				}
			}
			q.Status = "approved"
			if q.Kind == "policy" {
				c.Policy = *q.Policy
			}
		}
	case "lesson.complete":
		if adult {
			return "forbidden"
		}
		if !settings.LearningEnabled {
			return "feature_disabled"
		}
		found := false
		for _, l := range lessonCatalogue {
			if l.ID == in.EntityID {
				if in.AnswerIndex == nil || *in.AnswerIndex < 0 || *in.AnswerIndex >= len(l.Options) {
					return "invalid_answer"
				}
				if *in.AnswerIndex != l.CorrectAnswer {
					return "wrong_answer"
				}
				found = true
			}
		}
		if !found {
			return "not_found"
		}
		key := c.ID + ":" + in.EntityID
		if _, ok := f.Learning[key]; !ok {
			f.Learning[key] = LessonCompletion{ChildID: c.ID, LessonID: in.EntityID, CompletedAt: s.cfg.Now().Unix()}
		}
	default:
		return "invalid_command_type"
	}
	return ""
}

func matchAvailable(g *Goal, p SpaceSettings) int64 {
	if !p.MatchingEnabled || p.MatchingPercent == 0 {
		return 0
	}
	n := (g.SavedMinor - g.MatchedMinor - g.MatchedBasisMinor) * p.MatchingPercent / 100
	if n < 0 {
		return 0
	}
	if cap := p.MatchingCapMinor - g.MatchedMinor; n > cap {
		n = cap
	}
	if n < 0 {
		return 0
	}
	return n
}

func (s *Server) spaceTransfer(st *State, c *Child, n int64) string {
	if !positiveMoney(n) {
		return "invalid_amount"
	}
	if c.AccountStatus != "synthetic_open" || c.AgreementStatus != "synthetic_signed" || c.IdentityStatus != "verified" {
		return "product_unavailable"
	}
	if st.FamilySpace.Wallet.AvailableMinor < n {
		return "insufficient_adult_balance"
	}
	if len(st.Operations) >= 10000 {
		return "ledger_limit"
	}
	if !credit(c, n) {
		return "balance_limit"
	}
	st.FamilySpace.Wallet.AvailableMinor -= n
	o := &Operation{ID: id(), ChildID: c.ID, Kind: "topup", AmountMinor: n, Currency: "BYN", Category: "other", Merchant: "Семейный перевод", Status: "done", CreatedAt: s.cfg.Now().Unix(), CompletedAt: s.cfg.Now().Unix(), Version: 1}
	st.Operations[o.ID] = o
	return ""
}

// validateSpace is a final storage gate: holds must equal the unsettled work
// liabilities, and every monetary bucket stays nonnegative and bounded.
func validateSpace(st State) error {
	f := st.FamilySpace
	if f == nil {
		return nil
	}
	bad := func() error { return errors.New("family money invariant violated") }
	if f.Wallet.AvailableMinor < 0 || f.Wallet.ReservedMinor < 0 || f.Wallet.AvailableMinor > moneyCap || f.Wallet.ReservedMinor > moneyCap || f.Wallet.Currency != "BYN" {
		return bad()
	}
	var held int64
	for _, t := range f.Tasks {
		if workOpen(t.Status) {
			held += t.RewardMinor
		}
	}
	for _, e := range f.Errands {
		if e.Funding == "reimburse" && e.RewardReserved {
			held += e.RewardMinor
		}
		if e.Funding == "funded" && e.Status != "approved" && e.Status != "canceled" {
			held += e.BudgetMinor + e.RewardMinor
		}
	}
	if held != f.Wallet.ReservedMinor {
		return bad()
	}
	for _, c := range st.Children {
		if c.BalanceMinor < 0 || c.BalanceMinor > moneyCap {
			return bad()
		}
	}
	for _, g := range f.Goals {
		if g.SavedMinor < 0 || g.SavedMinor > moneyCap || g.NetDepositsMinor != max(int64(0), g.SavedMinor-g.MatchedMinor) || g.MatchedMinor < 0 {
			return bad()
		}
	}
	return nil
}

// Archiving revokes child access. Reject it before any mutation while a goal,
// hold or incurred reimbursement still needs that access to settle safely.
func hasPendingFamilyObligations(st State, childID string) bool {
	f := st.FamilySpace
	if f == nil {
		return false
	}
	for _, g := range f.Goals {
		if g.ChildID == childID && g.SavedMinor > 0 {
			return true
		}
	}
	for _, t := range f.Tasks {
		if t.ChildID == childID && workOpen(t.Status) {
			return true
		}
	}
	for _, e := range f.Errands {
		if e.ChildID != childID || e.Status == "approved" || e.Status == "canceled" {
			continue
		}
		if e.Funding == "funded" || e.RewardReserved || e.ActualMinor > 0 {
			return true
		}
	}
	return false
}
