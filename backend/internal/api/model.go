package api

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"time"
)

type Policy struct {
	Categories        map[string]bool `json:"categories"`
	Payments          bool            `json:"payments"`
	Transfers         bool            `json:"transfers"`
	Internet          bool            `json:"internet"`
	DailyLimit        int64           `json:"dailyLimit"`
	MonthlyLimit      int64           `json:"monthlyLimit"`
	ApprovalThreshold int64           `json:"approvalThreshold"`
}
type Child struct {
	ID                   string `json:"id"`
	DisplayName          string `json:"displayName"`
	LegalName            string `json:"legalName"`
	DateOfBirth          string `json:"dateOfBirth"`
	IdentityStatus       string `json:"identityStatus"`
	RepresentationStatus string `json:"representationStatus"`
	AgreementStatus      string `json:"agreementStatus"`
	AccountStatus        string `json:"accountStatus"`
	CardStatus           string `json:"cardStatus"`
	DeviceAccessStatus   string `json:"deviceAccessStatus"`
	MembershipStatus     string `json:"membershipStatus"`
	Policy               Policy `json:"policy"`
	BalanceMinor         int64  `json:"balanceMinor"`
	Currency             string `json:"currency"`
	AgreementVersion     string `json:"agreementVersion,omitempty"`
	SignerID             string `json:"signerId,omitempty"`
	SignedAt             int64  `json:"signedAt,omitempty"`
	Version              int64  `json:"version"`
}
type Session struct {
	ID         string `json:"id"`
	Role       string `json:"role"`
	ChildID    string `json:"childId,omitempty"`
	DeviceName string `json:"deviceName"`
	TokenHash  string `json:"tokenHash"`
	ExpiresAt  int64  `json:"expiresAt"`
	Revoked    bool   `json:"revoked"`
}
type Pairing struct {
	ID           string `json:"id"`
	CodeHash     string `json:"codeHash"`
	SecretHash   string `json:"secretHash"`
	DeviceName   string `json:"deviceName"`
	ChildID      string `json:"childId,omitempty"`
	ExpiresAt    int64  `json:"expiresAt"`
	Status       string `json:"status"`
	DeliverySalt string `json:"deliverySalt,omitempty"`
	SessionID    string `json:"sessionId,omitempty"`
}
type ChildCreateCommand struct {
	ChildID     string `json:"childId"`
	Fingerprint string `json:"fingerprint"`
}
type AdultPreferences struct {
	FamilyIntroSeen bool `json:"familyIntroSeen"`
}
type State struct {
	FamilySpace  *FamilySpaceState             `json:"familySpace,omitempty"`
	Revision     int64                         `json:"revision"`
	AdultID      string                        `json:"adultId"`
	Preferences  AdultPreferences              `json:"preferences"`
	Children     map[string]*Child             `json:"children"`
	Sessions     map[string]*Session           `json:"sessions"`
	Pairings     map[string]*Pairing           `json:"pairings"`
	Operations   map[string]*Operation         `json:"operations"`
	ChildCreates map[string]ChildCreateCommand `json:"childCreates"`
}
type Actor struct {
	ID        string `json:"id"`
	Role      string `json:"role"`
	ChildID   string `json:"childId,omitempty"`
	SessionID string `json:"sessionId"`
}
type Snapshot struct {
	FamilySpace  FamilySpaceSnapshot `json:"familySpace"`
	Revision     int64               `json:"revision"`
	Actor        Actor               `json:"actor"`
	Preferences  *AdultPreferences   `json:"preferences,omitempty"`
	Children     []*Child            `json:"children"`
	Operations   []*Operation        `json:"operations"`
	Synthetic    bool                `json:"synthetic"`
	BusinessDate string              `json:"businessDate"`
}

func randomToken() string {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		panic("random source unavailable")
	}
	return hex.EncodeToString(b)
}
func id() string           { return randomToken()[:32] }
func hash(s string) string { v := sha256.Sum256([]byte(s)); return hex.EncodeToString(v[:]) }
func clone(s State) State  { b, _ := json.Marshal(s); var c State; _ = json.Unmarshal(b, &c); return c }
func validPolicy(p Policy) bool {
	for category := range p.Categories {
		if !familyCategory(category) {
			return false
		}
	}
	return p.DailyLimit >= 0 && p.DailyLimit <= 10000000 && p.MonthlyLimit >= p.DailyLimit && p.MonthlyLimit <= 100000000 && p.ApprovalThreshold >= 0 && p.ApprovalThreshold <= 10000000
}
func validDOB(d string, now time.Time) bool {
	t, e := time.Parse("2006-01-02", d)
	return e == nil && !t.After(now.AddDate(-7, 0, 0)) && t.After(now.AddDate(-18, 0, 0))
}

func familyCategory(c string) bool {
	switch c {
	case "food", "transport", "entertainment", "other":
		return true
	}
	return false
}
func defaultCategories() map[string]bool {
	return map[string]bool{"food": true, "transport": true, "entertainment": true, "other": true}
}
