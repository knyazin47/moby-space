package api

import (
	"bytes"
	"encoding/json"
	"testing"
	"time"
)

func TestReadOnlyReviewFullMatchingWithdrawal(t *testing.T) {
	f := setup(t)
	c, child := readyChild(t, f)
	p := defaultSpaceSettings()
	p.MatchingEnabled = true
	p.MatchingPercent = 50
	p.MatchingCapMinor = 10000
	spaceCall(t, f, f.token, SpaceCommand{Type: "settings.update", ChildID: c, Settings: &p, IdempotencyKey: "review-settings"}, 200)
	spaceCall(t, f, child, SpaceCommand{Type: "goal.create", ChildID: c, Title: "Review", TargetMinor: 10000, IdempotencyKey: "review-goal-create"}, 200)
	var gid string
	for k := range f.s.state.FamilySpace.Goals {
		gid = k
	}
	x := SpaceCommand{Type: "goal.move", ChildID: c, EntityID: gid, Action: "deposit", AmountMinor: 1000, IdempotencyKey: "review-deposit-1"}
	spaceCall(t, f, child, x, 200)
	spaceCall(t, f, f.token, SpaceCommand{Type: "goal.match", ChildID: c, EntityID: gid, AmountMinor: 500, IdempotencyKey: "review-match-1"}, 200)
	x.Action = "withdraw"
	x.AmountMinor = 1500
	x.IdempotencyKey = "review-withdraw-1"
	spaceCall(t, f, child, x, 200)
	x.Action = "deposit"
	x.IdempotencyKey = "review-deposit-2"
	spaceCall(t, f, child, x, 200)
	if got := matchAvailable(f.s.state.FamilySpace.Goals[gid], p); got != 0 {
		t.Fatalf("recycled matching money eligible again: got %d want0", got)
	}
}
func TestReadOnlyReviewArchiveHeldTask(t *testing.T) {
	f := setup(t)
	c, child := readyChild(t, f)
	spaceCall(t, f, f.token, SpaceCommand{Type: "task.create", ChildID: c, Title: "Review", RewardMinor: 500, IdempotencyKey: "review-task-create"}, 200)
	var tid string
	for k := range f.s.state.FamilySpace.Tasks {
		tid = k
	}
	spaceCall(t, f, child, SpaceCommand{Type: "task.action", ChildID: c, EntityID: tid, Action: "accept", IdempotencyKey: "review-task-accept"}, 200)
	code, v := f.call("POST", "/v1/children/"+c+"/archive", f.token, nil)
	if code != 409 {
		t.Errorf("archive with500 held accepted: got%d %v want409", code, v)
	}
	code, v = f.call("POST", "/v1/family-space/commands", f.token, SpaceCommand{Type: "task.action", ChildID: c, EntityID: tid, Action: "cancel", Reason: "Release", IdempotencyKey: "review-task-cancel"})
	if code != 200 || f.s.state.FamilySpace.Wallet.ReservedMinor != 0 {
		t.Fatalf("blocked archive prevented safe settlement: status%d %v", code, v)
	}
}
func TestReadOnlyReviewLegacyTopupAfterRejection(t *testing.T) {
	f := setup(t)
	c, _ := readyChild(t, f)
	code, v := f.call("POST", "/v1/children/"+c+"/verification", f.token, map[string]string{"outcome": "rejected"})
	if code != 200 {
		t.Fatal(code, v)
	}
	code, v = f.call("POST", "/v1/children/"+c+"/topups", f.token, map[string]any{"amountMinor": 100, "currency": "BYN", "idempotencyKey": "review-legacy-topup"})
	if code != 409 {
		t.Fatalf("legacy topup credited rejected identity: got%d %v want409", code, v)
	}
}

func TestLegacyTopupRevalidatesProductWithoutMovingFunds(t *testing.T) {
	for _, outcome := range []string{"pending", "rejected", "needs_correction"} {
		t.Run(outcome, func(t *testing.T) {
			f := setup(t)
			c, _ := readyChild(t, f)
			code, _ := f.call("POST", "/v1/children/"+c+"/verification", f.token, map[string]string{"outcome": outcome})
			if code != 200 {
				t.Fatal("verification setup failed")
			}
			beforeWallet := f.s.state.FamilySpace.Wallet
			beforeBalance := balance(f, c)
			beforeRevision := f.s.state.Revision
			beforeCount := len(f.s.state.Operations)
			input := map[string]any{"amountMinor": 100, "currency": "BYN", "idempotencyKey": "guarded-legacy-topup"}
			code, _ = f.call("POST", "/v1/children/"+c+"/topups", f.token, input)
			if code != 409 {
				t.Fatal("legacy transfer accepted invalid identity")
			}
			spaceCall(t, f, f.token, SpaceCommand{Type: "wallet.transfer", ChildID: c, AmountMinor: 100, IdempotencyKey: "guarded-v2-transfer"}, 409)
			if f.s.state.FamilySpace.Wallet != beforeWallet || balance(f, c) != beforeBalance || f.s.state.Revision != beforeRevision || len(f.s.state.Operations) != beforeCount {
				t.Fatal("rejected transfer changed money, ledger or revision")
			}
			f.call("POST", "/v1/children/"+c+"/verification", f.token, map[string]string{"outcome": "verified"})
			code, _ = f.call("POST", "/v1/children/"+c+"/topups", f.token, input)
			if code != 201 || balance(f, c) != beforeBalance+100 {
				t.Fatal("verified product did not recover transfer")
			}
		})
	}
}

func TestSpaceChildImmediateCardBlockOwnScopeAndUnblockGuard(t *testing.T) {
	f := setup(t)
	c, child := readyChild(t, f)
	other := f.child("Other")
	block := SpaceCommand{Type: "card.block", ChildID: other, IdempotencyKey: "protect-other-card"}
	spaceCall(t, f, child, block, 403)
	if f.s.state.Children[c].CardStatus != "active" {
		t.Fatal("wrong-scope command changed own card")
	}
	block.ChildID = c
	block.IdempotencyKey = "protect-my-card"
	spaceCall(t, f, child, block, 200)
	revision := f.s.state.Revision
	spaceCall(t, f, child, block, 200)
	if f.s.state.Revision != revision || f.s.state.Children[c].CardStatus != "blocked" {
		t.Fatal("protect replay changed state")
	}
	code, _ := f.call("POST", "/v1/children/"+c+"/operations", child, map[string]any{"amountMinor": 100, "currency": "BYN", "channel": "pos", "idempotencyKey": "purchase-after-protect"})
	if code != 409 || balance(f, c) != 20000 {
		t.Fatal("blocked card purchased")
	}
	code, _ = f.call("PATCH", "/v1/children/"+c, child, map[string]string{"cardStatus": "active"})
	if code != 403 {
		t.Fatal("child unblocked card")
	}
	code, _ = f.call("PATCH", "/v1/children/"+c, f.token, map[string]string{"cardStatus": "active"})
	if code != 200 {
		t.Fatal("adult cannot unblock valid card")
	}
	// Protection remains available with rejected identity, while parent unblocking
	// retains existing current-verification and signed-product requirements.
	f.call("POST", "/v1/children/"+c+"/verification", f.token, map[string]string{"outcome": "rejected"})
	block.IdempotencyKey = "protect-rejected-identity"
	spaceCall(t, f, child, block, 200)
	code, _ = f.call("PATCH", "/v1/children/"+c, f.token, map[string]string{"cardStatus": "active"})
	if code != 409 {
		t.Fatal("adult unblocked rejected identity")
	}
	spaceCall(t, f, f.token, SpaceCommand{Type: "card.block", ChildID: other, IdempotencyKey: "protect-unopened-card"}, 409)
	noticeFound := false
	for _, n := range f.s.state.FamilySpace.Notices {
		if n.Kind == "card.block" && n.ChildID == c && n.Recipient == "adult" && n.Mandatory {
			noticeFound = true
		}
	}
	if !noticeFound {
		t.Fatal("protect did not notify adult")
	}
}
func TestSpaceAdministrativeReleaseAfterIdentityRejection(t *testing.T) {
	for _, kind := range []string{"task", "funded_errand", "reimburse_reward", "allowance"} {
		t.Run(kind, func(t *testing.T) {
			f := setup(t)
			c, child := readyChild(t, f)
			var entity string
			var command SpaceCommand
			switch kind {
			case "task":
				spaceCall(t, f, f.token, SpaceCommand{Type: "task.create", ChildID: c, Title: "Task", RewardMinor: 500, IdempotencyKey: "rejected-task-create"}, 200)
				for k := range f.s.state.FamilySpace.Tasks {
					entity = k
				}
				spaceCall(t, f, child, SpaceCommand{Type: "task.action", ChildID: c, EntityID: entity, Action: "accept", IdempotencyKey: "rejected-task-accept"}, 200)
				command = SpaceCommand{Type: "task.action", Action: "cancel", Reason: "Отменено взрослым"}
			case "funded_errand", "reimburse_reward":
				funding := "funded"
				if kind == "reimburse_reward" {
					funding = "reimburse"
				}
				spaceCall(t, f, f.token, SpaceCommand{Type: "errand.create", ChildID: c, Title: "Errand", BudgetMinor: 500, RewardMinor: 100, Funding: funding, IdempotencyKey: "rejected-errand-create"}, 200)
				for k := range f.s.state.FamilySpace.Errands {
					entity = k
				}
				spaceCall(t, f, child, SpaceCommand{Type: "errand.action", ChildID: c, EntityID: entity, Action: "accept", OwnMoneyConsent: true, IdempotencyKey: "rejected-errand-accept"}, 200)
				command = SpaceCommand{Type: "errand.action", Action: "cancel", Reason: "Отменено взрослым"}
			case "allowance":
				spaceCall(t, f, f.token, SpaceCommand{Type: "allowance.create", ChildID: c, Title: "Allowance", AmountMinor: 500, Frequency: "daily", NextDate: dateString(f.s.familyDate()), IdempotencyKey: "rejected-allowance-create"}, 200)
				for k := range f.s.state.FamilySpace.Allowances {
					entity = k
				}
				command = SpaceCommand{Type: "allowance.action", Action: "pause"}
			}
			f.call("POST", "/v1/children/"+c+"/verification", f.token, map[string]string{"outcome": "rejected"})
			beforeBalance := balance(f, c)
			command.ChildID = c
			command.EntityID = entity
			command.IdempotencyKey = "rejected-administrative-release"
			if command.Action == "cancel" {
				withoutReason := command
				withoutReason.Reason = ""
				spaceCall(t, f, f.token, withoutReason, 400)
			}
			spaceCall(t, f, f.token, command, 200)
			spaceCall(t, f, f.token, command, 200)
			if balance(f, c) != beforeBalance || f.s.state.FamilySpace.Wallet.ReservedMinor != 0 || f.s.state.FamilySpace.Wallet.AvailableMinor != 80000 {
				t.Fatal("administrative release transferred/duplicated money")
			}
			if kind == "allowance" && f.s.state.FamilySpace.Allowances[entity].Active {
				t.Fatal("invalid identity prevented pause")
			}
		})
	}
}

func TestSpaceAllowanceUpdateOnlyFuturePreservesHistoryAndPause(t *testing.T) {
	f := setup(t)
	c, child := readyChild(t, f)
	now := f.s.cfg.Now().In(minskLocation)
	f.s.cfg.Now = func() time.Time { return now }
	today := dateString(f.s.familyDate())
	create := SpaceCommand{Type: "allowance.create", ChildID: c, Title: "Paid", AmountMinor: 500, Frequency: "daily", NextDate: today, IdempotencyKey: "edit-paid-create"}
	spaceCall(t, f, f.token, create, 200)
	var paidID string
	for k := range f.s.state.FamilySpace.Allowances {
		paidID = k
	}
	_ = f.s.RunDue()
	create.Title = "Insufficient"
	create.AmountMinor = 100000
	create.IdempotencyKey = "edit-insufficient-create"
	spaceCall(t, f, f.token, create, 200)
	var insufficientID string
	for k := range f.s.state.FamilySpace.Allowances {
		if k != paidID {
			insufficientID = k
		}
	}
	_ = f.s.RunDue()
	spaceCall(t, f, f.token, SpaceCommand{Type: "allowance.action", ChildID: c, EntityID: paidID, Action: "pause", IdempotencyKey: "edit-paid-pause"}, 200)
	history, _ := json.Marshal(f.s.state.FamilySpace.Installments)
	wallet := f.s.state.FamilySpace.Wallet
	available := balance(f, c)
	edit := SpaceCommand{Type: "allowance.update", ChildID: c, EntityID: paidID, Title: "New weekdays", AmountMinor: 700, Frequency: "weekly", Weekdays: []int{(int(now.Weekday()) + 1) % 7, (int(now.Weekday()) + 3) % 7}, NextDate: today, RetryLimit: 2, IdempotencyKey: "edit-existing-paid"}
	spaceCall(t, f, child, edit, 403)
	spaceCall(t, f, f.token, edit, 200)
	spaceCall(t, f, f.token, edit, 200)
	a := f.s.state.FamilySpace.Allowances[paidID]
	if a.ID != paidID || a.ChildID != c || a.Active || a.AmountMinor != 700 || len(a.Weekdays) != 2 || a.NextDate != dateString(f.s.familyDate().AddDate(0, 0, 1)) {
		t.Fatal("edit lost identity, pause or weekday adjustment")
	}
	edited, _ := json.Marshal(a)
	revision := f.s.state.Revision
	bad := edit
	bad.IdempotencyKey = "edit-invalid-past"
	bad.NextDate = dateString(f.s.familyDate().AddDate(0, 0, -1))
	spaceCall(t, f, f.token, bad, 400)
	after, _ := json.Marshal(f.s.state.FamilySpace.Allowances[paidID])
	if string(after) != string(edited) || f.s.state.Revision != revision {
		t.Fatal("invalid edit changed schedule")
	}
	bad = edit
	bad.IdempotencyKey = "edit-invalid-duplicates"
	bad.Weekdays = []int{1, 1}
	spaceCall(t, f, f.token, bad, 400)
	// Changing a schedule's retry preference cannot opt old insufficient periods in.
	edit.EntityID = insufficientID
	edit.IdempotencyKey = "edit-old-insufficient"
	edit.Frequency = "daily"
	edit.NextDate = dateString(f.s.familyDate().AddDate(0, 0, 5))
	edit.AmountMinor = 1000
	edit.RetryLimit = 3
	spaceCall(t, f, f.token, edit, 200)
	afterHistory, _ := json.Marshal(f.s.state.FamilySpace.Installments)
	if string(afterHistory) != string(history) {
		t.Fatal("edit changed existing installment")
	}
	now = now.AddDate(0, 0, 1)
	if err := f.s.RunDue(); err != nil {
		t.Fatal(err)
	}
	afterHistory, _ = json.Marshal(f.s.state.FamilySpace.Installments)
	if string(afterHistory) != string(history) || f.s.state.FamilySpace.Wallet != wallet || balance(f, c) != available {
		t.Fatal("edit retroactively paid or retried old periods")
	}
}
func TestSpaceAllowanceUpdateTodayNeverRepaysExistingOccurrence(t *testing.T) {
	f := setup(t)
	c, _ := readyChild(t, f)
	today := dateString(f.s.familyDate())
	spaceCall(t, f, f.token, SpaceCommand{Type: "allowance.create", ChildID: c, Title: "Original", AmountMinor: 500, Frequency: "daily", NextDate: today, IdempotencyKey: "today-edit-create"}, 200)
	_ = f.s.RunDue()
	var aid string
	for k := range f.s.state.FamilySpace.Allowances {
		aid = k
	}
	history, _ := json.Marshal(f.s.state.FamilySpace.Installments)
	wallet := f.s.state.FamilySpace.Wallet
	available := balance(f, c)
	spaceCall(t, f, f.token, SpaceCommand{Type: "allowance.update", ChildID: c, EntityID: aid, Title: "Edited today", AmountMinor: 900, Frequency: "daily", NextDate: today, RetryLimit: 0, IdempotencyKey: "today-edit-update"}, 200)
	_ = f.s.RunDue()
	_ = f.s.RunDue()
	after, _ := json.Marshal(f.s.state.FamilySpace.Installments)
	if string(after) != string(history) || f.s.state.FamilySpace.Wallet != wallet || balance(f, c) != available {
		t.Fatal("today update repaid existing period")
	}
}

func TestSpaceActivityScopedBoundedAndSeparateFromLegacy(t *testing.T) {
	f := setup(t)
	c, child := readyChild(t, f)
	other := f.child("Activity sibling")
	_, snap := f.call("GET", "/v1/snapshot", child, nil)
	activity := snap["familySpace"].(map[string]any)["activity"].([]any)
	if len(activity) != 0 {
		t.Fatal("opening endowment or legacy topup leaked into child activity")
	}
	_, snap = f.call("GET", "/v1/snapshot", f.token, nil)
	activity = snap["familySpace"].(map[string]any)["activity"].([]any)
	if len(activity) != 1 || activity[0].(map[string]any)["kind"] != "demo_opening_endowment" {
		t.Fatal("adult opening audit missing")
	}
	spaceCall(t, f, child, SpaceCommand{Type: "goal.create", ChildID: c, Title: "Activity", TargetMinor: 1000, IdempotencyKey: "activity-goal-create"}, 200)
	var gid string
	for k := range f.s.state.FamilySpace.Goals {
		gid = k
	}
	spaceCall(t, f, child, SpaceCommand{Type: "goal.move", ChildID: c, EntityID: gid, Action: "deposit", AmountMinor: 100, IdempotencyKey: "activity-goal-deposit"}, 200)
	f.s.mu.Lock()
	st := clone(f.s.state)
	f.s.spaceEntry(&st, other, "task_complete", "sibling-private-event", 0)
	if err := f.s.save(st); err != nil {
		f.s.mu.Unlock()
		t.Fatal(err)
	}
	f.s.mu.Unlock()
	_, snap = f.call("GET", "/v1/snapshot", child, nil)
	activity = snap["familySpace"].(map[string]any)["activity"].([]any)
	if len(activity) != 1 {
		t.Fatal("child activity not filtered")
	}
	entry := activity[0].(map[string]any)
	if entry["kind"] != "goal_deposit" || entry["childId"] != c || entry["entityId"] != gid || entry["amountMinor"].(float64) != 100 {
		t.Fatal("activity payload lost event")
	}
	if _, exists := entry["requestHash"]; exists {
		t.Fatal("private fingerprint leaked")
	}
	f.s.mu.Lock()
	st = clone(f.s.state)
	for i := 0; i < 205; i++ {
		f.s.spaceEntry(&st, c, "task_complete", "bounded-fixture-event", 0)
	}
	if err := f.s.save(st); err != nil {
		f.s.mu.Unlock()
		t.Fatal(err)
	}
	f.s.mu.Unlock()
	_, snap = f.call("GET", "/v1/snapshot", child, nil)
	activity = snap["familySpace"].(map[string]any)["activity"].([]any)
	if len(activity) != 200 {
		t.Fatal("activity limit not applied after child filtering")
	}
	var previousAt float64
	var previousID string
	for i, raw := range activity {
		e := raw.(map[string]any)
		at := e["at"].(float64)
		eid := e["id"].(string)
		if e["childId"] != c || e["kind"] == "demo_opening_endowment" || e["entityId"] == "sibling-private-event" {
			t.Fatal("scope leak after limiting")
		}
		if i > 0 && (at > previousAt || at == previousAt && eid > previousID) {
			t.Fatal("activity not newest first")
		}
		previousAt = at
		previousID = eid
	}
}

func TestSpacePolicyFingerprintVersionSeparatesEmptyFromOmitted(t *testing.T) {
	f := setup(t)
	c, child := readyChild(t, f)
	p := f.s.state.Children[c].Policy
	p.Categories = nil
	command := SpaceCommand{Type: "request.create", ChildID: c, Kind: "policy", Title: "Rules", Policy: &p, IdempotencyKey: "policy-version-two"}
	spaceCall(t, f, child, command, 200)
	p.Categories = map[string]bool{}
	spaceCall(t, f, child, command, 409)
	// A legacy persisted record still acknowledges the old canonical payload,
	// without executing the request again or altering a previously paid state.
	p.Categories = nil
	command.IdempotencyKey = "legacy-policy-fingerprint"
	raw, _ := json.Marshal(command)
	raw = bytes.ReplaceAll(raw, []byte(`"categories":null,`), nil)
	key := hash(c + ":space:" + command.IdempotencyKey)
	f.s.mu.Lock()
	st := clone(f.s.state)
	st.FamilySpace.Commands[key] = SpaceCommandRecord{Fingerprint: hash(string(raw))}
	if e := f.s.save(st); e != nil {
		f.s.mu.Unlock()
		t.Fatal(e)
	}
	revision := f.s.state.Revision
	f.s.mu.Unlock()
	spaceCall(t, f, child, command, 200)
	if f.s.state.Revision != revision {
		t.Fatal("legacy replay re-executed command")
	}
}
