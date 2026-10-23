package api

import (
	"net/http"
	"time"
)

type Operation struct {
	ID          string `json:"id"`
	ChildID     string `json:"childId"`
	Kind        string `json:"kind"`
	AmountMinor int64  `json:"amountMinor"`
	Currency    string `json:"currency"`
	Channel     string `json:"channel"`
	Category    string `json:"category"`
	CompletedAt int64  `json:"completedAt,omitempty"`
	Merchant    string `json:"merchant"`
	Status      string `json:"status"`
	CreatedAt   int64  `json:"createdAt"`
	Version     int64  `json:"version"`
	Decision    *bool  `json:"decision,omitempty"`
	RequestKey  string `json:"requestKey,omitempty"`
	RequestHash string `json:"requestHash,omitempty"`
}
type moneyInput struct {
	AmountMinor    int64  `json:"amountMinor"`
	Currency       string `json:"currency"`
	Channel        string `json:"channel"`
	Category       string `json:"category"`
	Merchant       string `json:"merchant"`
	IdempotencyKey string `json:"idempotencyKey"`
}

func (s *Server) product(w http.ResponseWriter, r *http.Request) {
	var in ProductInput
	if !decode(w, r, &in) {
		return
	}
	result, e := s.AppProduct(r.Context(), requestToken(r), r.PathValue("id"), in)
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) purchase(w http.ResponseWriter, r *http.Request) { s.money(w, r, false) }
func (s *Server) topup(w http.ResponseWriter, r *http.Request)    { s.money(w, r, true) }
func (s *Server) money(w http.ResponseWriter, r *http.Request, topup bool) {
	var in MoneyInput
	if !decode(w, r, &in) {
		return
	}
	result, e := s.AppMoney(r.Context(), requestToken(r), r.PathValue("id"), in, topup)
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) purchaseGuard(st State, c *Child, o *Operation) string {
	if c.MembershipStatus != "active" || !s.hasActiveChildSession(st, c.ID) || c.DeviceAccessStatus != "paired" || c.CardStatus != "active" || c.AccountStatus != "synthetic_open" || c.IdentityStatus != "verified" || c.RepresentationStatus != "synthetic_verified" {
		return "product_unavailable"
	}
	if (o.Channel != "pos" && o.Channel != "internet") || !familyCategory(o.Category) {
		return "category_prohibited"
	}
	if c.Policy.Categories != nil && !c.Policy.Categories[o.Category] {
		return "category_disabled"
	}
	if !c.Policy.Payments || (o.Channel == "internet" && !c.Policy.Internet) {
		return "permission_denied"
	}
	if c.BalanceMinor < o.AmountMinor {
		return "insufficient_balance"
	}
	var daily, monthly int64
	now := s.cfg.Now().In(minskLocation)
	for _, old := range st.Operations {
		if old.ChildID != c.ID || old.Kind != "purchase" || old.Status != "done" {
			continue
		}
		d := time.Unix(old.CompletedAt, 0).In(minskLocation)
		if d.Year() == now.Year() && d.Month() == now.Month() {
			monthly += old.AmountMinor
			if d.Day() == now.Day() {
				daily += old.AmountMinor
			}
		}
	}
	if daily+o.AmountMinor > c.Policy.DailyLimit || monthly+o.AmountMinor > c.Policy.MonthlyLimit {
		return "limit_exceeded"
	}
	return ""
}
func (s *Server) decision(w http.ResponseWriter, r *http.Request) {
	var in DecisionInput
	if !decode(w, r, &in) {
		return
	}
	result, e := s.AppDecision(r.Context(), requestToken(r), r.PathValue("id"), in)
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
