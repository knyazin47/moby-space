package api

import (
	"encoding/json"
	"fmt"
	"net/http/httptest"
	"path/filepath"
	"testing"
	"time"
)

func spaceCall(t *testing.T, f *fixture, token string, in SpaceCommand, want int) map[string]any {
	t.Helper()
	code, v := f.call("POST", "/v1/family-space/commands", token, in)
	if code != want {
		t.Fatalf("%s/%s got %d %v want %d", in.Type, in.Action, code, v, want)
	}
	return v
}
func TestSpaceTaskHoldCancelPayoutAndScope(t *testing.T) {
	f := setup(t)
	c, child := readyChild(t, f)
	other := f.child("Sibling")
	create := SpaceCommand{Type: "task.create", ChildID: c, Title: "Help", RewardMinor: 500, IdempotencyKey: "offer-task-1"}
	spaceCall(t, f, f.token, create, 200)
	var task string
	for k := range f.s.state.FamilySpace.Tasks {
		task = k
	}
	act := SpaceCommand{Type: "task.action", ChildID: c, EntityID: task, Action: "accept", IdempotencyKey: "accept-task-1"}
	spaceCall(t, f, child, act, 200)
	spaceCall(t, f, child, act, 200)
	if f.s.state.FamilySpace.Wallet.ReservedMinor != 500 {
		t.Fatal("hold duplicated")
	}
	act.Action = "cancel"
	act.IdempotencyKey = "adult-cancel-1"
	spaceCall(t, f, f.token, act, 400)
	act.Action = "dispute"
	act.IdempotencyKey = "child-dispute-1"
	spaceCall(t, f, child, act, 200)
	if f.s.state.FamilySpace.Wallet.ReservedMinor != 500 {
		t.Fatal("dispute lost hold")
	}
	act.Action = "submit"
	act.IdempotencyKey = "submit-task-1"
	spaceCall(t, f, child, act, 200)
	act.Action = "approve"
	act.IdempotencyKey = "approve-task-1"
	spaceCall(t, f, f.token, act, 200)
	spaceCall(t, f, f.token, act, 200)
	act.IdempotencyKey = "approve-task-2"
	spaceCall(t, f, f.token, act, 409)
	if balance(f, c) != 20500 || f.s.state.FamilySpace.Wallet.ReservedMinor != 0 {
		t.Fatal("incorrect payout")
	}
	_, v := f.call("GET", "/v1/snapshot", child, nil)
	raw, _ := json.Marshal(v)
	fs := v["familySpace"].(map[string]any)
	if _, ok := fs["adultWallet"]; ok {
		t.Fatal("adult balance leaked")
	}
	if string(raw) == "" || len(fs["settings"].(map[string]any)) != 1 {
		t.Fatal("scope")
	}
	act.ChildID = other
	spaceCall(t, f, child, act, 403)
	create.IdempotencyKey = "offer-task-2"
	spaceCall(t, f, f.token, create, 200)
	for k, v := range f.s.state.FamilySpace.Tasks {
		if v.Status == "offered" {
			task = k
		}
	}
	act = SpaceCommand{Type: "task.action", ChildID: c, EntityID: task, Action: "accept", IdempotencyKey: "accept-task-2"}
	spaceCall(t, f, child, act, 200)
	act.Action = "request_cancel"
	act.IdempotencyKey = "cancel-request-2"
	spaceCall(t, f, f.token, act, 200)
	act.Action = "agree_cancel"
	act.IdempotencyKey = "agree-cancel-2"
	spaceCall(t, f, child, act, 200)
	if f.s.state.FamilySpace.Wallet.ReservedMinor != 0 {
		t.Fatal("cancel retained hold")
	}
}
func TestSpaceGoalsMatchingNoFarming(t *testing.T) {
	f := setup(t)
	c, child := readyChild(t, f)
	spaceCall(t, f, child, SpaceCommand{Type: "goal.create", ChildID: c, Title: "Bike", TargetMinor: 10000, IdempotencyKey: "create-goal-1"}, 200)
	var goal string
	for k := range f.s.state.FamilySpace.Goals {
		goal = k
	}
	move := SpaceCommand{Type: "goal.move", ChildID: c, EntityID: goal, AmountMinor: 1000, Action: "deposit", IdempotencyKey: "deposit-goal-1"}
	spaceCall(t, f, child, move, 200)
	settings := defaultSpaceSettings()
	settings.MatchingEnabled = true
	settings.MatchingPercent = 50
	settings.MatchingCapMinor = 1000
	spaceCall(t, f, f.token, SpaceCommand{Type: "settings.update", ChildID: c, Settings: &settings, IdempotencyKey: "settings-goal-1"}, 200)
	match := SpaceCommand{Type: "goal.match", ChildID: c, EntityID: goal, AmountMinor: 500, IdempotencyKey: "matching-goal-1"}
	spaceCall(t, f, f.token, match, 409)
	move.IdempotencyKey = "deposit-goal-2"
	spaceCall(t, f, child, move, 200)
	spaceCall(t, f, f.token, match, 200)
	if f.s.state.FamilySpace.Goals[goal].SavedMinor != 2500 || balance(f, c) != 18000 {
		t.Fatal("goal money wrong")
	}
	move.Action = "withdraw"
	move.AmountMinor = 2000
	move.IdempotencyKey = "withdraw-goal-1"
	spaceCall(t, f, child, move, 200)
	move.Action = "deposit"
	move.IdempotencyKey = "deposit-goal-3"
	spaceCall(t, f, child, move, 200)
	match.IdempotencyKey = "matching-goal-2"
	spaceCall(t, f, f.token, match, 409)
	if f.s.state.FamilySpace.Goals[goal].MatchedMinor != 500 {
		t.Fatal("farming")
	}
}
func TestSpaceErrandConsentEarmarkAndRemainder(t *testing.T) {
	for _, funding := range []string{"funded", "reimburse"} {
		t.Run(funding, func(t *testing.T) {
			f := setup(t)
			c, child := readyChild(t, f)
			spaceCall(t, f, f.token, SpaceCommand{Type: "errand.create", ChildID: c, Title: "Groceries", BudgetMinor: 1000, RewardMinor: 100, Funding: funding, IdempotencyKey: "errand-create-1"}, 200)
			var e string
			for k := range f.s.state.FamilySpace.Errands {
				e = k
			}
			act := SpaceCommand{Type: "errand.action", ChildID: c, EntityID: e, Action: "accept", IdempotencyKey: "errand-accept-1"}
			if funding == "reimburse" {
				spaceCall(t, f, child, act, 409)
				act.OwnMoneyConsent = true
			}
			spaceCall(t, f, child, act, 200)
			act.Action = "submit"
			act.AmountMinor = 700
			act.IdempotencyKey = "errand-submit-1"
			spaceCall(t, f, child, act, 200)
			spaceCall(t, f, child, act, 200)
			act.Action = "approve"
			act.IdempotencyKey = "errand-approve-1"
			if funding == "funded" {
				spaceCall(t, f, f.token, act, 409)
				ret := act
				ret.Action = "return"
				ret.IdempotencyKey = "errand-return-1"
				spaceCall(t, f, child, ret, 200)
			}
			spaceCall(t, f, f.token, act, 200)
			spaceCall(t, f, f.token, act, 200)
			if balance(f, c) != 20100 || f.s.state.FamilySpace.Wallet.AvailableMinor != 79200 || f.s.state.FamilySpace.Wallet.ReservedMinor != 0 {
				t.Fatal("errand accounting")
			}
		})
	}
}
func TestSpaceSchedulerBatchMinskMissedAndRestart(t *testing.T) {
	f := setup(t)
	c, _ := readyChild(t, f)
	d := f.child("Second")
	f.pair(d)
	f.call("POST", "/v1/children/"+d+"/verification", f.token, map[string]string{"outcome": "verified"})
	f.call("POST", "/v1/children/"+d+"/product", f.token, map[string]any{"agreementVersion": "synthetic-v1", "signerConsent": true})
	f.call("POST", "/v1/children/"+d+"/topups", f.token, map[string]any{"amountMinor": 20000, "currency": "BYN", "idempotencyKey": "second-initial-topup"})
	now := time.Date(2026, 10, 20, 21, 30, 0, 0, time.UTC)
	f.s.cfg.Now = func() time.Time { return now }
	for i, cid := range []string{c, d} {
		spaceCall(t, f, f.token, SpaceCommand{Type: "allowance.create", ChildID: cid, Title: "Pocket money", AmountMinor: 40000, Frequency: "daily", NextDate: "2026-10-21", RetryLimit: 1, IdempotencyKey: fmt.Sprintf("allowance-create-%d", i)}, 200)
	}
	if err := f.s.RunDue(); err != nil {
		t.Fatal(err)
	}
	if balance(f, c) != 20000 || balance(f, d) != 20000 {
		t.Fatal("implicit sibling priority")
	}
	if len(f.s.state.FamilySpace.Installments) != 2 {
		t.Fatal("wrong due date")
	}
	for _, p := range f.s.state.FamilySpace.Installments {
		if p.Status != "insufficient" || p.Attempts != 1 {
			t.Fatal("wrong batch status")
		}
	}
	_ = f.s.RunDue()
	for _, p := range f.s.state.FamilySpace.Installments {
		if p.Attempts != 1 {
			t.Fatal("same-day retry")
		}
	}
	now = now.AddDate(0, 0, 3)
	_ = f.s.RunDue()
	missed := 0
	for _, p := range f.s.state.FamilySpace.Installments {
		if p.Status == "missed" {
			missed++
		}
	}
	if missed != 4 {
		t.Fatal("missed period catchup")
	}
	path := f.s.cfg.DatabasePath
	cfg := f.s.cfg
	f.s.Close()
	s, e := New(cfg)
	if e != nil {
		t.Fatal(e)
	}
	defer s.Close()
	if s.cfg.DatabasePath != path || s.state.FamilySpace.Wallet.AvailableMinor != 60000 || len(s.state.FamilySpace.Installments) != 8 {
		t.Fatal("restart changed money")
	}
}
func TestSpaceOpeningMigrationOnce(t *testing.T) {
	path := filepath.Join(t.TempDir(), "family.sqlite")
	cfg := Config{DatabasePath: path, BootstrapSecret: testSecret}
	s, e := New(cfg)
	if e != nil {
		t.Fatal(e)
	}
	st := clone(s.state)
	st.FamilySpace = nil
	st.Children["legacy"] = &Child{ID: "legacy", BalanceMinor: 12345}
	if e = s.save(st); e != nil {
		t.Fatal(e)
	}
	s.Close()
	s, e = New(cfg)
	if e != nil {
		t.Fatal(e)
	}
	if s.state.Children["legacy"].BalanceMinor != 12345 || s.state.FamilySpace.Wallet.AvailableMinor != 100000 {
		t.Fatal("migration reset balances")
	}
	s.Close()
	s, e = New(cfg)
	if e != nil {
		t.Fatal(e)
	}
	defer s.Close()
	if len(s.state.FamilySpace.Entries) != 1 || !s.state.FamilySpace.BootstrapRecorded {
		t.Fatal("migration minted twice")
	}
}

func TestSpaceTransfersRequestsAndLearning(t *testing.T) {
	f := setup(t)
	c, child := readyChild(t, f)
	transfer := SpaceCommand{Type: "wallet.transfer", ChildID: c, AmountMinor: 1000, IdempotencyKey: "wallet-transfer-1"}
	spaceCall(t, f, f.token, transfer, 200)
	spaceCall(t, f, f.token, transfer, 200)
	spaceCall(t, f, child, transfer, 403)
	request := SpaceCommand{Type: "request.create", ChildID: c, Kind: "money", Title: "Books", AmountMinor: 500, IdempotencyKey: "money-request-1"}
	spaceCall(t, f, child, request, 200)
	var rid string
	for k := range f.s.state.FamilySpace.Requests {
		rid = k
	}
	yes := true
	decision := SpaceCommand{Type: "request.decide", ChildID: c, EntityID: rid, Approve: &yes, IdempotencyKey: "money-decision-1"}
	spaceCall(t, f, f.token, decision, 200)
	spaceCall(t, f, f.token, decision, 200)
	decision.IdempotencyKey = "money-decision-2"
	spaceCall(t, f, f.token, decision, 409)
	if balance(f, c) != 21500 || f.s.state.FamilySpace.Wallet.AvailableMinor != 78500 {
		t.Fatal("transfers not conserved")
	}
	tooMuch := transfer
	tooMuch.IdempotencyKey = "wallet-transfer-large"
	tooMuch.AmountMinor = 100000
	spaceCall(t, f, f.token, tooMuch, 409)
	before := f.s.state.Children[c].Policy
	wrong := 1
	lesson := SpaceCommand{Type: "lesson.complete", ChildID: c, EntityID: "needs-wants", AnswerIndex: &wrong, IdempotencyKey: "complete-lesson-1"}
	spaceCall(t, f, child, lesson, 400)
	if len(f.s.state.FamilySpace.Learning) != 0 {
		t.Fatal("wrong answer completed")
	}
	right := 0
	lesson.AnswerIndex = &right
	spaceCall(t, f, child, lesson, 200)
	spaceCall(t, f, child, lesson, 200)
	if len(f.s.state.FamilySpace.Learning) != 1 || balance(f, c) != 21500 || f.s.state.Children[c].Policy.DailyLimit != before.DailyLimit {
		t.Fatal("learning changed money/policy")
	}
	_, v := f.call("GET", "/v1/snapshot", child, nil)
	data, _ := json.Marshal(v["familySpace"])
	if string(data) == "" {
		t.Fatal("no snapshot")
	}
	for _, l := range v["familySpace"].(map[string]any)["lessons"].([]any) {
		if _, exists := l.(map[string]any)["correctAnswer"]; exists {
			t.Fatal("answer leaked")
		}
	}
}
func TestSpaceAllowancePayOnceRetryManualAndMonthClamp(t *testing.T) {
	f := setup(t)
	c, _ := readyChild(t, f)
	now := f.s.cfg.Now().In(minskLocation)
	f.s.cfg.Now = func() time.Time { return now }
	today := dateString(f.s.familyDate())
	spaceCall(t, f, f.token, SpaceCommand{Type: "allowance.create", ChildID: c, Title: "Daily", AmountMinor: 500, Frequency: "daily", NextDate: today, RetryLimit: 0, IdempotencyKey: "daily-allowance-1"}, 200)
	_ = f.s.RunDue()
	_ = f.s.RunDue()
	if balance(f, c) != 20500 {
		t.Fatal("allowance double paid")
	}
	if e := validateSpace(f.s.state); e != nil {
		t.Fatal(e)
	}
	monthly := &Allowance{Frequency: "monthly", MonthDay: 31}
	feb, _ := parseFamilyDate("2027-02-01")
	if nextAllowanceDate(monthly, feb) != "2027-02-28" {
		t.Fatal("monthly clamp")
	}
	spaceCall(t, f, f.token, SpaceCommand{Type: "allowance.create", ChildID: c, Title: "Large", AmountMinor: 100000, Frequency: "daily", NextDate: today, RetryLimit: 1, IdempotencyKey: "large-allowance-1"}, 200)
	_ = f.s.RunDue()
	var unpaid string
	for k, p := range f.s.state.FamilySpace.Installments {
		if p.Status == "insufficient" {
			unpaid = k
		}
	}
	if unpaid == "" {
		t.Fatal("missing insufficient")
	}
	// Explicit cancellation is terminal and cannot be automatically retried.
	spaceCall(t, f, f.token, SpaceCommand{Type: "allowance.action", ChildID: c, EntityID: unpaid, Action: "cancel", IdempotencyKey: "cancel-installment-1"}, 200)
	now = now.AddDate(0, 0, 1)
	_ = f.s.RunDue()
	if f.s.state.FamilySpace.Installments[unpaid].Status != "canceled" {
		t.Fatal("canceled installment retried")
	}
}

func TestSpaceAdultReasonedCancelAndInbox(t *testing.T) {
	f := setup(t)
	c, child := readyChild(t, f)
	p := defaultSpaceSettings()
	p.Notifications = false
	spaceCall(t, f, f.token, SpaceCommand{Type: "settings.update", ChildID: c, Settings: &p, IdempotencyKey: "notice-settings-1"}, 200)
	spaceCall(t, f, f.token, SpaceCommand{Type: "task.create", ChildID: c, Title: "Work", RewardMinor: 800, IdempotencyKey: "cancel-offer-1"}, 200)
	var tid string
	for k := range f.s.state.FamilySpace.Tasks {
		tid = k
	}
	act := SpaceCommand{Type: "task.action", ChildID: c, EntityID: tid, Action: "accept", IdempotencyKey: "cancel-accept-1"}
	spaceCall(t, f, child, act, 200)
	act.Action = "submit"
	act.IdempotencyKey = "cancel-submit-1"
	spaceCall(t, f, child, act, 200)
	act.Action = "cancel"
	act.IdempotencyKey = "cancel-reason-1"
	spaceCall(t, f, f.token, act, 400)
	act.Reason = "Задание больше не нужно"
	spaceCall(t, f, f.token, act, 200)
	spaceCall(t, f, f.token, act, 200)
	if f.s.state.FamilySpace.Wallet.ReservedMinor != 0 || balance(f, c) != 20000 || f.s.state.FamilySpace.Tasks[tid].CancelReason != act.Reason {
		t.Fatal("reasoned cancel accounting/history")
	}
	_, snap := f.call("GET", "/v1/snapshot", child, nil)
	notices := snap["familySpace"].(map[string]any)["notices"].([]any)
	var nid string
	for _, raw := range notices {
		n := raw.(map[string]any)
		if n["recipient"] != "child" || n["childId"] != c {
			t.Fatal("notice scope leaked")
		}
		if n["kind"] == "task.create" {
			t.Fatal("routine preference ignored")
		}
		if n["kind"] == "task.action" {
			nid = n["id"].(string)
		}
	}
	if nid == "" {
		t.Fatal("mandatory confirmation suppressed")
	}
	read := SpaceCommand{Type: "notice.read", ChildID: c, EntityID: nid, IdempotencyKey: "notice-read-1"}
	spaceCall(t, f, f.token, read, 403)
	spaceCall(t, f, child, read, 200)
	if !f.s.state.FamilySpace.Notices[nid].Read {
		t.Fatal("notice not read")
	}
}
func TestSpaceReimburseRewardHeldAndExpenseProtected(t *testing.T) {
	f := setup(t)
	c, child := readyChild(t, f)
	spaceCall(t, f, f.token, SpaceCommand{Type: "errand.create", ChildID: c, Title: "Purchase", BudgetMinor: 1000, RewardMinor: 300, Funding: "reimburse", IdempotencyKey: "reimburse-offer-1"}, 200)
	var eid string
	for k := range f.s.state.FamilySpace.Errands {
		eid = k
	}
	act := SpaceCommand{Type: "errand.action", ChildID: c, EntityID: eid, Action: "accept", OwnMoneyConsent: true, IdempotencyKey: "reimburse-accept-1"}
	spaceCall(t, f, child, act, 200)
	if f.s.state.FamilySpace.Wallet.ReservedMinor != 300 {
		t.Fatal("reward not reserved")
	}
	act.Action = "submit"
	act.AmountMinor = 700
	act.IdempotencyKey = "reimburse-submit-1"
	spaceCall(t, f, child, act, 200)
	act.Action = "cancel"
	act.Reason = "Отмена"
	act.IdempotencyKey = "reimburse-cancel-1"
	spaceCall(t, f, f.token, act, 409)
	if f.s.state.FamilySpace.Wallet.ReservedMinor != 300 || balance(f, c) != 19300 {
		t.Fatal("expense or reward erased")
	}
	act.Action = "approve"
	act.IdempotencyKey = "reimburse-approve-1"
	spaceCall(t, f, f.token, act, 200)
	if f.s.state.FamilySpace.Wallet.ReservedMinor != 0 || balance(f, c) != 20300 {
		t.Fatal("wrong reimbursement")
	}
}

func TestSpaceInsufficientBatchManualPriorityAndBoundedRetry(t *testing.T) {
	f := setup(t)
	c, child := readyChild(t, f)
	now := f.s.cfg.Now().In(minskLocation)
	f.s.cfg.Now = func() time.Time { return now }
	today := dateString(f.s.familyDate())
	for i := 0; i < 2; i++ {
		spaceCall(t, f, f.token, SpaceCommand{Type: "allowance.create", ChildID: c, Title: "Manual priorities", AmountMinor: 50000, Frequency: "weekly", Weekdays: []int{int(now.Weekday())}, NextDate: today, IdempotencyKey: fmt.Sprintf("manual-schedule-%d", i)}, 200)
	}
	_ = f.s.RunDue()
	var installment string
	for k, p := range f.s.state.FamilySpace.Installments {
		if p.Status != "insufficient" {
			t.Fatal("batch partial funded")
		}
		installment = k
	}
	settle := SpaceCommand{Type: "allowance.action", ChildID: c, EntityID: installment, Action: "settle", IdempotencyKey: "manual-settle-1"}
	spaceCall(t, f, f.token, settle, 200)
	spaceCall(t, f, f.token, settle, 200)
	if balance(f, c) != 70000 {
		t.Fatal("manual doublepay")
	}
	// A separate opted-in weekly installment retries only once per next day.
	spaceCall(t, f, f.token, SpaceCommand{Type: "task.create", ChildID: c, Title: "Reserve", RewardMinor: 29500, IdempotencyKey: "retry-task-create"}, 200)
	var tid string
	for k := range f.s.state.FamilySpace.Tasks {
		tid = k
	}
	act := SpaceCommand{Type: "task.action", ChildID: c, EntityID: tid, Action: "accept", IdempotencyKey: "retry-task-accept"}
	spaceCall(t, f, child, act, 200)
	spaceCall(t, f, f.token, SpaceCommand{Type: "allowance.create", ChildID: c, Title: "Retry", AmountMinor: 1000, Frequency: "weekly", Weekdays: []int{int(now.Weekday())}, NextDate: today, RetryLimit: 1, IdempotencyKey: "retry-schedule-1"}, 200)
	_ = f.s.RunDue()
	var retry string
	for k, p := range f.s.state.FamilySpace.Installments {
		if p.AmountMinor == 1000 {
			retry = k
			if p.Attempts != 1 || p.Status != "insufficient" {
				t.Fatal("retry initial")
			}
		}
	}
	act.Action = "cancel"
	act.Reason = "Освободить бюджет"
	act.IdempotencyKey = "retry-task-cancel"
	spaceCall(t, f, f.token, act, 200)
	now = now.AddDate(0, 0, 1)
	_ = f.s.RunDue()
	_ = f.s.RunDue()
	if f.s.state.FamilySpace.Installments[retry].Attempts != 2 || f.s.state.FamilySpace.Installments[retry].Status != "paid" || balance(f, c) != 71000 {
		t.Fatal("retry not exact once")
	}
}

func TestSpaceMatchingCannotRecycleWithdrawnReward(t *testing.T) {
	f := setup(t)
	c, child := readyChild(t, f)
	spaceCall(t, f, child, SpaceCommand{Type: "goal.create", ChildID: c, Title: "No recycling", TargetMinor: 10000, IdempotencyKey: "recycle-create-1"}, 200)
	var gid string
	for k := range f.s.state.FamilySpace.Goals {
		gid = k
	}
	p := defaultSpaceSettings()
	p.MatchingEnabled = true
	p.MatchingPercent = 50
	p.MatchingCapMinor = 10000
	spaceCall(t, f, f.token, SpaceCommand{Type: "settings.update", ChildID: c, Settings: &p, IdempotencyKey: "recycle-settings-1"}, 200)
	move := SpaceCommand{Type: "goal.move", ChildID: c, EntityID: gid, Action: "deposit", AmountMinor: 1000, IdempotencyKey: "recycle-deposit-1"}
	spaceCall(t, f, child, move, 200)
	spaceCall(t, f, f.token, SpaceCommand{Type: "goal.match", ChildID: c, EntityID: gid, AmountMinor: 500, IdempotencyKey: "recycle-match-1"}, 200)
	for i := 0; i < 3; i++ {
		move.Action = "withdraw"
		move.AmountMinor = 1500
		move.IdempotencyKey = fmt.Sprintf("recycle-withdraw-%d", i)
		spaceCall(t, f, child, move, 200)
		if i == 1 {
			// A fresh server must recover the matching debt while the goal is empty.
			cfg := f.s.cfg
			f.http.Close()
			f.s.Close()
			reopened, e := New(cfg)
			if e != nil {
				t.Fatal(e)
			}
			f.s = reopened
			f.http = httptest.NewServer(reopened)
			t.Cleanup(func() { reopened.Close() })
		}
		move.Action = "deposit"
		move.IdempotencyKey = fmt.Sprintf("recycle-redeposit-%d", i)
		v := spaceCall(t, f, child, move, 200)
		goals := v["familySpace"].(map[string]any)["goals"].([]any)
		if goals[0].(map[string]any)["matchingAvailableMinor"].(float64) != 0 {
			t.Fatal("recycled matching became eligible")
		}
		match := SpaceCommand{Type: "goal.match", ChildID: c, EntityID: gid, AmountMinor: 250, IdempotencyKey: fmt.Sprintf("recycle-newmatch-%d", i)}
		spaceCall(t, f, f.token, match, 409)
	}
	move.AmountMinor = 400
	move.Action = "withdraw"
	move.IdempotencyKey = "recycle-partial-out"
	spaceCall(t, f, child, move, 200)
	move.Action = "deposit"
	move.IdempotencyKey = "recycle-partial-in"
	spaceCall(t, f, child, move, 200)
	if matchAvailable(f.s.state.FamilySpace.Goals[gid], p) != 0 {
		t.Fatal("partial recycling became eligible")
	}
	// Only money beyond the previously matched principal becomes eligible.
	move.AmountMinor = 100
	move.IdempotencyKey = "recycle-fresh-principal"
	spaceCall(t, f, child, move, 200)
	if matchAvailable(f.s.state.FamilySpace.Goals[gid], p) != 50 {
		t.Fatal("new principal lost eligibility")
	}
	if f.s.state.FamilySpace.Goals[gid].MatchedMinor != 500 || balance(f, c) != 18900 {
		t.Fatal("unexpected conserved balances")
	}
}
func TestSpaceArchiveRejectsObligationsBeforeRevoking(t *testing.T) {
	for _, kind := range []string{"goal", "task", "funded_errand", "own_expense"} {
		t.Run(kind, func(t *testing.T) {
			f := setup(t)
			c, child := readyChild(t, f)
			var entity string
			switch kind {
			case "goal":
				spaceCall(t, f, child, SpaceCommand{Type: "goal.create", ChildID: c, Title: "Goal", TargetMinor: 500, IdempotencyKey: "archive-goal-create"}, 200)
				for k := range f.s.state.FamilySpace.Goals {
					entity = k
				}
				spaceCall(t, f, child, SpaceCommand{Type: "goal.move", ChildID: c, EntityID: entity, Action: "deposit", AmountMinor: 500, IdempotencyKey: "archive-goal-deposit"}, 200)
			case "task":
				spaceCall(t, f, f.token, SpaceCommand{Type: "task.create", ChildID: c, Title: "Task", RewardMinor: 500, IdempotencyKey: "archive-task-create"}, 200)
				for k := range f.s.state.FamilySpace.Tasks {
					entity = k
				}
				spaceCall(t, f, child, SpaceCommand{Type: "task.action", ChildID: c, EntityID: entity, Action: "accept", IdempotencyKey: "archive-task-accept"}, 200)
			default:
				funding := "funded"
				if kind == "own_expense" {
					funding = "reimburse"
				}
				spaceCall(t, f, f.token, SpaceCommand{Type: "errand.create", ChildID: c, Title: "Errand", BudgetMinor: 500, Funding: funding, IdempotencyKey: "archive-errand-create"}, 200)
				for k := range f.s.state.FamilySpace.Errands {
					entity = k
				}
				if kind == "own_expense" {
					spaceCall(t, f, child, SpaceCommand{Type: "errand.action", ChildID: c, EntityID: entity, Action: "accept", OwnMoneyConsent: true, IdempotencyKey: "archive-errand-accept"}, 200)
					spaceCall(t, f, child, SpaceCommand{Type: "errand.action", ChildID: c, EntityID: entity, Action: "submit", AmountMinor: 400, IdempotencyKey: "archive-errand-submit"}, 200)
				}
			}
			revision := f.s.state.Revision
			code, v := f.call("POST", "/v1/children/"+c+"/archive", f.token, nil)
			if code != 409 || v["error"] != "pending_family_obligations" {
				t.Fatalf("archive trapped %s: %d %v", kind, code, v)
			}
			if f.s.state.Revision != revision || f.s.state.Children[c].MembershipStatus != "active" {
				t.Fatal("failed archive mutated state")
			}
			code, _ = f.call("GET", "/v1/snapshot", child, nil)
			if code != 200 {
				t.Fatal("failed archive revoked child")
			}
			switch kind {
			case "goal":
				spaceCall(t, f, child, SpaceCommand{Type: "goal.move", ChildID: c, EntityID: entity, Action: "withdraw", AmountMinor: 500, IdempotencyKey: "archive-goal-withdraw"}, 200)
			case "task":
				spaceCall(t, f, f.token, SpaceCommand{Type: "task.action", ChildID: c, EntityID: entity, Action: "cancel", Reason: "Завершено обсуждением", IdempotencyKey: "archive-task-cancel"}, 200)
			case "funded_errand":
				spaceCall(t, f, f.token, SpaceCommand{Type: "errand.action", ChildID: c, EntityID: entity, Action: "cancel", Reason: "Поручение не нужно", IdempotencyKey: "archive-errand-cancel"}, 200)
			case "own_expense":
				spaceCall(t, f, f.token, SpaceCommand{Type: "errand.action", ChildID: c, EntityID: entity, Action: "approve", IdempotencyKey: "archive-errand-approve"}, 200)
			}
			code, v = f.call("POST", "/v1/children/"+c+"/archive", f.token, nil)
			if code != 200 {
				t.Fatalf("settled child archive failed: %d %v", code, v)
			}
			code, _ = f.call("GET", "/v1/snapshot", child, nil)
			if code != 401 {
				t.Fatal("successful archive retained child access")
			}
		})
	}
}
