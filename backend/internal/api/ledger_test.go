package api

import (
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

func readyChild(t *testing.T, f *fixture) (string, string) {
	t.Helper()
	c := f.child("Ledger child")
	token, _ := f.pair(c)
	code, _ := f.call("POST", "/v1/children/"+c+"/product", f.token, map[string]any{"agreementVersion": "synthetic-v1", "signerConsent": true})
	if code != 409 {
		t.Fatal("name/pairing created product")
	}
	code, _ = f.call("POST", "/v1/children/"+c+"/verification", f.token, map[string]string{"outcome": "verified"})
	if code != 200 {
		t.Fatal("verification failed")
	}
	code, _ = f.call("POST", "/v1/children/"+c+"/product", f.token, map[string]any{"agreementVersion": "synthetic-v1", "signerConsent": true})
	if code != 200 {
		t.Fatal("synthetic issue failed")
	}
	code, _ = f.call("POST", "/v1/children/"+c+"/topups", f.token, map[string]any{"amountMinor": 20000, "currency": "BYN", "idempotencyKey": "initial-topup"})
	if code != 201 {
		t.Fatal("topup failed")
	}
	return c, token
}
func balance(f *fixture, c string) float64 {
	_, v := f.call("GET", "/v1/children/"+c, f.token, nil)
	return v["balanceMinor"].(float64)
}
func TestLedgerGuardsIdempotencyDecision(t *testing.T) {
	f := setup(t)
	c, token := readyChild(t, f)
	body := map[string]any{"amountMinor": -100, "currency": "BYN", "channel": "pos", "merchant": "Synthetic shop", "idempotencyKey": "purchase-1"}
	code, _ := f.call("POST", "/v1/children/"+c+"/operations", token, body)
	if code != 400 || balance(f, c) != 20000 {
		t.Fatal("negative money changed balance")
	}
	body["amountMinor"] = 6000
	code, v := f.call("POST", "/v1/children/"+c+"/operations", token, body)
	if code != 201 || v["status"] != "pending" || balance(f, c) != 20000 {
		t.Fatal("pending operation moved money")
	}
	operation := v["id"].(string)
	code, repeat := f.call("POST", "/v1/children/"+c+"/operations", token, body)
	if code != 200 || repeat["id"] != operation {
		t.Fatal("retry duplicated intent")
	}
	body["amountMinor"] = 6100
	code, _ = f.call("POST", "/v1/children/"+c+"/operations", token, body)
	if code != 409 {
		t.Fatal("idempotency collision accepted")
	}
	var count atomic.Int32
	var wg sync.WaitGroup
	for range 5 {
		wg.Go(func() {
			code, _ := f.call("POST", "/v1/operations/"+operation+"/decision", f.token, map[string]bool{"approve": true})
			if code == 200 {
				count.Add(1)
			}
		})
	}
	wg.Wait()
	if count.Load() != 5 || balance(f, c) != 14000 {
		t.Fatal("decision not exactly once")
	}
	code, _ = f.call("POST", "/v1/operations/"+operation+"/decision", f.token, map[string]bool{"approve": false})
	if code != 409 {
		t.Fatal("terminal decision changed")
	}
	body["amountMinor"] = 4000
	body["idempotencyKey"] = "purchase-2"
	code, _ = f.call("POST", "/v1/children/"+c+"/operations", token, body)
	if code != 201 || balance(f, c) != 10000 {
		t.Fatal("immediate purchase failed")
	}
	body["amountMinor"] = 1
	body["idempotencyKey"] = "purchase-3"
	code, _ = f.call("POST", "/v1/children/"+c+"/operations", token, body)
	if code != 409 {
		t.Fatal("daily limit bypassed")
	}
	code, _ = f.call("POST", "/v1/children/"+c+"/topups", token, map[string]any{"amountMinor": 1, "currency": "BYN", "idempotencyKey": "child-topup"})
	if code != 403 {
		t.Fatal("child minted funds")
	}
}
func TestApprovalRevalidatesPolicyAndCard(t *testing.T) {
	for _, guard := range []string{"payments", "internet", "card", "balance", "limit", "identity", "membership"} {
		t.Run(guard, func(t *testing.T) {
			f := setup(t)
			c, token := readyChild(t, f)
			code, v := f.call("POST", "/v1/children/"+c+"/operations", token, map[string]any{"amountMinor": 6000, "currency": "BYN", "channel": "pos", "merchant": "Synthetic shop", "idempotencyKey": "pending-intent"})
			if code != 201 {
				t.Fatal(v)
			}
			operation := v["id"].(string)
			f.s.mu.Lock()
			st := clone(f.s.state)
			child := st.Children[c]
			switch guard {
			case "payments":
				child.Policy.Payments = false
			case "internet":
				st.Operations[operation].Channel = "internet"
			case "card":
				child.CardStatus = "blocked"
			case "balance":
				child.BalanceMinor = 0
			case "limit":
				child.Policy.DailyLimit = 5000
			case "identity":
				child.IdentityStatus = "needs_correction"
			case "membership":
				child.MembershipStatus = "archived"
			}
			_ = f.s.save(st)
			f.s.mu.Unlock()
			before := balance(f, c)
			code, _ = f.call("POST", "/v1/operations/"+operation+"/decision", f.token, map[string]bool{"approve": true})
			if code != 409 || balance(f, c) != before {
				t.Fatal("approval bypassed current " + guard)
			}
		})
	}
}
func TestSyntheticVerificationAndSessionDeliveryRecovery(t *testing.T) {
	f := setup(t)
	c := f.child("Draft")
	for _, outcome := range []string{"pending", "needs_correction", "rejected", "verified"} {
		code, v := f.call("POST", "/v1/children/"+c+"/verification", f.token, map[string]string{"outcome": outcome})
		if code != 200 || v["identityStatus"] != outcome || v["accountStatus"] != "not_opened" || v["cardStatus"] != "none" {
			t.Fatal("verification conflated with product")
		}
	}
	_, p := f.call("POST", "/v1/pairings", "", map[string]string{"deviceName": "phone"})
	f.call("POST", "/v1/pairings/consume", f.token, map[string]any{"code": p["code"], "childId": c})
	path := "/v1/pairings/" + p["id"].(string) + "/poll"
	_, one := f.call("POST", path, "", map[string]any{"requestSecret": p["requestSecret"]})
	_, two := f.call("POST", path, "", map[string]any{"requestSecret": p["requestSecret"]})
	first := one["session"].(map[string]any)
	second := two["session"].(map[string]any)
	if first["token"] != second["token"] {
		t.Fatal("retry minted new token")
	}
	sid := first["actor"].(map[string]any)["sessionId"].(string)
	f.call("POST", "/v1/sessions/"+sid+"/revoke", f.token, nil)
	code, _ := f.call("POST", path, "", map[string]any{"requestSecret": p["requestSecret"]})
	if code != 409 {
		t.Fatal("pair retry restored revoked session")
	}
}

func TestApprovalSpendsAtCompletionAndCategoryGuards(t *testing.T) {
	f := setup(t)
	c, token := readyChild(t, f)
	code, v := f.call("POST", "/v1/children/"+c+"/operations", token, map[string]any{"amountMinor": 6000, "currency": "BYN", "channel": "pos", "category": "food", "merchant": "Shop", "idempotencyKey": "yesterday-pending"})
	if code != 201 {
		t.Fatal(v)
	}
	operation := v["id"].(string)
	f.s.mu.Lock()
	st := clone(f.s.state)
	st.Operations[operation].CreatedAt -= 40 * 24 * 60 * 60
	_ = f.s.save(st)
	f.s.mu.Unlock()
	code, _ = f.call("POST", "/v1/operations/"+operation+"/decision", f.token, map[string]bool{"approve": true})
	if code != 200 {
		t.Fatal("approve old pending")
	}
	code, _ = f.call("POST", "/v1/children/"+c+"/operations", token, map[string]any{"amountMinor": 5000, "currency": "BYN", "channel": "pos", "category": "food", "idempotencyKey": "today-over-limit"})
	if code != 409 {
		t.Fatal("old intent evaded today's spend limit")
	}
	for _, category := range []string{"gambling", "adult", "unknown"} {
		code, _ = f.call("POST", "/v1/children/"+c+"/operations", token, map[string]any{"amountMinor": 1, "currency": "BYN", "channel": "pos", "category": category, "idempotencyKey": "denied-" + category})
		if code != 409 {
			t.Fatal("category bypass " + category)
		}
	}
	f.s.mu.Lock()
	st = clone(f.s.state)
	st.Children[c].Policy.Categories["food"] = false
	_ = f.s.save(st)
	f.s.mu.Unlock()
	code, _ = f.call("POST", "/v1/children/"+c+"/operations", token, map[string]any{"amountMinor": 1, "currency": "BYN", "channel": "pos", "category": "food", "idempotencyKey": "disabled-category"})
	if code != 409 {
		t.Fatal("family category bypass")
	}
}
func TestSignedIdentityLockedNicknameEditableAndStableRetry(t *testing.T) {
	f := setup(t)
	c, _ := readyChild(t, f)
	code, _ := f.call("PATCH", "/v1/children/"+c, f.token, map[string]string{"legalName": "Changed identity"})
	if code != 409 {
		t.Fatal("signed identity mutable")
	}
	code, _ = f.call("PATCH", "/v1/children/"+c, f.token, map[string]string{"displayName": "Nickname"})
	if code != 200 {
		t.Fatal("nickname locked")
	}
	before := balance(f, c)
	_, v := f.call("POST", "/v1/auth/adult", "", map[string]any{"bootstrapSecret": testSecret, "deviceName": "second adult device"})
	newToken := v["token"].(string)
	code, _ = f.call("POST", "/v1/children/"+c+"/topups", newToken, map[string]any{"amountMinor": 20000, "currency": "BYN", "idempotencyKey": "initial-topup"})
	if code != 200 || balance(f, c) != before {
		t.Fatal("new session repeated actor command")
	}
}

func TestMonthlyLimitUsesExecutionAndCategoryApprovalRevalidation(t *testing.T) {
	f := setup(t)
	c, token := readyChild(t, f)
	code, v := f.call("POST", "/v1/children/"+c+"/operations", token, map[string]any{"amountMinor": 6000, "currency": "BYN", "channel": "pos", "category": "food", "idempotencyKey": "prior-day-operation"})
	if code != 201 {
		t.Fatal(v)
	}
	operation := v["id"].(string)
	code, _ = f.call("POST", "/v1/operations/"+operation+"/decision", f.token, map[string]bool{"approve": true})
	if code != 200 {
		t.Fatal("approve initial operation")
	}
	f.s.mu.Lock()
	st := clone(f.s.state)
	fixedNow := f.s.cfg.Now().UTC()
	if fixedNow.Day() == 1 {
		fixedNow = fixedNow.AddDate(0, 0, 1)
		f.s.cfg.Now = func() time.Time { return fixedNow }
	}
	st.Operations[operation].CreatedAt = fixedNow.AddDate(0, -2, 0).Unix()
	st.Operations[operation].CompletedAt = fixedNow.AddDate(0, 0, -1).Unix()
	st.Children[c].Policy.MonthlyLimit = 10000
	_ = f.s.save(st)
	f.s.mu.Unlock()
	code, _ = f.call("POST", "/v1/children/"+c+"/operations", token, map[string]any{"amountMinor": 5000, "currency": "BYN", "channel": "pos", "category": "food", "idempotencyKey": "monthly-only-limit"})
	if code != 409 {
		t.Fatal("prior-day executed purchase missing from month limit")
	}
	code, v = f.call("POST", "/v1/children/"+c+"/operations", token, map[string]any{"amountMinor": 3000, "currency": "BYN", "channel": "pos", "category": "food", "idempotencyKey": "pending-category-recheck"})
	if code != 201 || v["status"] != "done" {
		t.Fatal("within month purchase unexpectedly failed")
	}
	f.s.mu.Lock()
	st = clone(f.s.state)
	st.Children[c].Policy.ApprovalThreshold = 100
	_ = f.s.save(st)
	f.s.mu.Unlock()
	code, v = f.call("POST", "/v1/children/"+c+"/operations", token, map[string]any{"amountMinor": 500, "currency": "BYN", "channel": "pos", "category": "food", "idempotencyKey": "pending-category-recheck-2"})
	if code != 201 || v["status"] != "pending" {
		t.Fatal("expected category pending intent")
	}
	operation = v["id"].(string)
	f.s.mu.Lock()
	st = clone(f.s.state)
	st.Children[c].Policy.Categories["food"] = false
	_ = f.s.save(st)
	f.s.mu.Unlock()
	before := balance(f, c)
	code, v = f.call("POST", "/v1/operations/"+operation+"/decision", f.token, map[string]bool{"approve": true})
	if code != 409 || v["error"] != "category_disabled" || balance(f, c) != before {
		t.Fatal("approval bypassed changed category policy")
	}
}
