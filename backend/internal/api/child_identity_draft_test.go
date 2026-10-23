package api

import "testing"

func TestChildNameDOBDraftRequiresDeferredIdentityAndSignedIdentityStaysLocked(t *testing.T) {
	f := setup(t)
	code, child := f.call("POST", "/v1/children", f.token, map[string]any{
		"displayName":    "Аня",
		"dateOfBirth":    "2015-01-02",
		"idempotencyKey": "name-dob-draft-1",
	})
	if code != 201 {
		t.Fatalf("create name/DOB draft: %d %v", code, child)
	}
	path := "/v1/children/" + child["id"].(string)
	if child["legalName"] != "" || child["identityStatus"] != "draft" ||
		child["representationStatus"] != "unverified" || child["agreementStatus"] != "not_signed" ||
		child["accountStatus"] != "not_opened" || child["cardStatus"] != "none" {
		t.Fatalf("name/DOB creation must leave identity and product unfinished: %v", child)
	}
	_, initialSnapshot := f.call("GET", "/v1/snapshot", f.token, nil)
	consent := map[string]any{"agreementVersion": "synthetic-v1", "signerConsent": true}
	code, response := f.call("POST", path+"/verification", f.token, map[string]string{"outcome": "verified"})
	if code != 400 || response["error"] != "legal_name_required" {
		t.Fatalf("blank legal name verification must fail: %d %v", code, response)
	}
	code, response = f.call("POST", path+"/product", f.token, consent)
	if code != 409 || response["error"] != "verification_required" {
		t.Fatalf("draft must not activate a product: %d %v", code, response)
	}
	_, rejectedSnapshot := f.call("GET", "/v1/snapshot", f.token, nil)
	if rejectedSnapshot["revision"] != initialSnapshot["revision"] {
		t.Fatal("rejected verification/product commands changed revision")
	}

	const legalName = "Синтетическая Анна"
	code, child = f.call("PATCH", path, f.token, map[string]string{"legalName": legalName})
	if code != 200 || child["legalName"] != legalName || child["identityStatus"] != "draft" ||
		child["representationStatus"] != "unverified" || child["accountStatus"] != "not_opened" {
		t.Fatalf("deferred legal name must not verify or open the product: %d %v", code, child)
	}
	code, child = f.call("POST", path+"/verification", f.token, map[string]string{"outcome": "verified"})
	if code != 200 || child["identityStatus"] != "verified" ||
		child["representationStatus"] != "synthetic_verified" || child["agreementStatus"] != "not_signed" ||
		child["accountStatus"] != "not_opened" || child["cardStatus"] != "none" {
		t.Fatalf("verification must remain separate from product opening: %d %v", code, child)
	}
	code, response = f.call("POST", path+"/product", f.token, map[string]any{
		"agreementVersion": "synthetic-v1", "signerConsent": false,
	})
	if code != 400 || response["error"] != "synthetic_consent_required" {
		t.Fatalf("verified identity must still require explicit product consent: %d %v", code, response)
	}
	code, child = f.call("POST", path+"/product", f.token, consent)
	if code != 200 || child["agreementStatus"] != "synthetic_signed" ||
		child["accountStatus"] != "synthetic_open" || child["cardStatus"] != "active" ||
		child["agreementVersion"] != "synthetic-v1" ||
		child["signerId"] != initialSnapshot["actor"].(map[string]any)["id"] ||
		child["signedAt"].(float64) <= 0 {
		t.Fatalf("verified and explicitly consented product must activate: %d %v", code, child)
	}

	_, signedSnapshot := f.call("GET", "/v1/snapshot", f.token, nil)
	for _, patch := range []map[string]string{
		{"legalName": "Изменённая Личность"},
		{"legalName": ""},
		{"dateOfBirth": "2014-01-02"},
	} {
		code, response = f.call("PATCH", path, f.token, patch)
		if code != 409 || response["error"] != "signed_identity_locked" {
			t.Fatalf("signed identity patch %v must stay locked: %d %v", patch, code, response)
		}
	}
	_, finalSnapshot := f.call("GET", "/v1/snapshot", f.token, nil)
	if finalSnapshot["revision"] != signedSnapshot["revision"] {
		t.Fatal("rejected signed identity edits changed revision")
	}
	code, final := f.call("GET", path, f.token, nil)
	if code != 200 {
		t.Fatalf("read signed profile: %d %v", code, final)
	}
	for _, field := range []string{"legalName", "dateOfBirth", "identityStatus", "representationStatus", "agreementStatus", "accountStatus", "cardStatus", "agreementVersion", "signerId", "signedAt", "version"} {
		if final[field] != child[field] {
			t.Fatalf("rejected signed identity edit changed %s: %v -> %v", field, child[field], final[field])
		}
	}
}
