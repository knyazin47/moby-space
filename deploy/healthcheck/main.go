package main

import (
	"encoding/json"
	"net/http"
	"os"
	"time"
)

func main() {
	client := &http.Client{Timeout: 2 * time.Second}
	r, e := client.Get("http://127.0.0.1:8080/healthz")
	if e != nil {
		os.Exit(1)
	}
	defer r.Body.Close()
	var v struct {
		OK        bool `json:"ok"`
		Synthetic bool `json:"synthetic"`
	}
	if r.StatusCode != 200 || json.NewDecoder(r.Body).Decode(&v) != nil || !v.OK || !v.Synthetic {
		os.Exit(1)
	}
}
