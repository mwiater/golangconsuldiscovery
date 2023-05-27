// Package hello handles requestss
package hello

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"time"

	"github.com/google/uuid"
	"github.com/mwiater/golangconsuldiscovery/structs"
)

var letters = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

func init() {
	rand.Seed(time.Now().UnixNano())
}

func HelloHandler(w http.ResponseWriter, r *http.Request, myUUID uuid.UUID) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Status", "200")
	hTTPResponse := structs.HTTPResponse{
		Status:      200,
		Application: "hello",
		UUID:        myUUID,
		Data:        randSeq(200000),
	}

	err := json.NewEncoder(w).Encode(hTTPResponse)
	if err != nil {
		fmt.Fprintf(w, "%+v", hTTPResponse)
	}
}

func HealthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "Service alive and reachable")
}

func randSeq(n int) string {
	b := make([]rune, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}
