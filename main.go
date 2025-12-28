package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"
)

type EchoRequest struct {
	Message string `json:"message"`
}

type EchoResponse struct {
	Message string `json:"message"`
	Service string `json:"service"`
}

func main() {
	port := getEnv("PORT", "8080")
	serviceName := getEnv("SERVICE_NAME", "just-cloud")

	mux := http.NewServeMux()

	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("OK"))
	})

	mux.HandleFunc("/echo", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			w.WriteHeader(http.StatusMethodNotAllowed)
			return
		}
		defer r.Body.Close()

		var req EchoRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			_, _ = w.Write([]byte(`{"error":"invalid json"}`))
			return
		}

		resp := EchoResponse{
			Message: req.Message,
			Service: serviceName,
		}

		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(resp); err != nil {
			log.Printf("encode error: %v", err)
		}
	})

	server := &http.Server{
		Addr:              ":" + port,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
	}

	log.Printf("just-cloud listening on :%s\n", port)

	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("server error: %v", err)
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}