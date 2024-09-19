package main

import (
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gorilla/mux"
)

func HelloHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Println("HelloHandler Worked")
	w.WriteHeader(http.StatusOK)
	w.Header().Set("Content-Type", "application/json")
	w.Write(([]byte(`{"message": "Hello, World!"}`)))
}

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/hello", HelloHandler)
	srv := &http.Server{
		Handler:      r,
		Addr:         "0.0.0.0:8080",
		WriteTimeout: 16 * time.Second,
		ReadTimeout:  16 * time.Second,
	}

	log.Println("Server started at: ", srv.Addr)
	log.Fatal(srv.ListenAndServe())
}
