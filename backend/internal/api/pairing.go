package api

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"net/http"
)

func (s *Server) createPair(w http.ResponseWriter, r *http.Request) {
	var in CreatePairInput
	if !decode(w, r, &in) {
		return
	}
	result, e := s.AppCreatePair(r.Context(), requestToken(r), in)
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) consumePair(w http.ResponseWriter, r *http.Request) {
	var in ConsumePairInput
	if !decode(w, r, &in) {
		return
	}
	result, e := s.AppConsumePair(r.Context(), requestToken(r), in)
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) pollPair(w http.ResponseWriter, r *http.Request) {
	var in PairSecretInput
	if !decode(w, r, &in) {
		return
	}
	result, e := s.AppPollPair(r.Context(), requestToken(r), r.PathValue("id"), in)
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}
func (s *Server) cancelPair(w http.ResponseWriter, r *http.Request) {
	var in PairSecretInput
	if !decode(w, r, &in) {
		return
	}
	result, e := s.AppCancelPair(r.Context(), requestToken(r), r.PathValue("id"), in)
	if e != nil {
		fail(w, e.Status, e.Code)
		return
	}
	write(w, result.Status, result.Value)
}

func deliveryToken(secret string, p *Pairing) string {
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(p.ID + ":" + p.DeliverySalt))
	return hex.EncodeToString(mac.Sum(nil))
}
