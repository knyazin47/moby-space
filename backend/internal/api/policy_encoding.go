package api

import "encoding/json"

// MarshalJSON preserves the published REST omission for a nil/default policy,
// while keeping an explicitly empty category map (deny-all) in clones/storage.
// The pointer wrapper makes {} different from nil without changing other field
// order used by persisted canonical command fingerprints.
func (p Policy) MarshalJSON() ([]byte, error) {
	var categories *map[string]bool
	if p.Categories != nil {
		categories = &p.Categories
	}
	return json.Marshal(struct {
		Categories        *map[string]bool `json:"categories,omitempty"`
		Payments          bool             `json:"payments"`
		Transfers         bool             `json:"transfers"`
		Internet          bool             `json:"internet"`
		DailyLimit        int64            `json:"dailyLimit"`
		MonthlyLimit      int64            `json:"monthlyLimit"`
		ApprovalThreshold int64            `json:"approvalThreshold"`
	}{categories, p.Payments, p.Transfers, p.Internet, p.DailyLimit, p.MonthlyLimit, p.ApprovalThreshold})
}
