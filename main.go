package main

import (
	"embed"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"

	"github.com/google/uuid"
	"github.com/mwiater/golangconsuldiscovery/config"
	"github.com/mwiater/golangconsuldiscovery/consul"
	"github.com/mwiater/golangconsuldiscovery/hello"
)

var myUUID = uuid.New()

//go:embed .env
var envVarsFile embed.FS

func main() {
	config.EnvVarsFile = envVarsFile

	_, err := config.AppConfig()
	if err != nil {
		log.Fatal("Error: config.AppConfig()")
	}

	signalChannel := make(chan os.Signal, 1)
	signal.Notify(signalChannel, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-signalChannel
		fmt.Println("\nShutting down.")
		os.Exit(0)
	}()

	consul.ServiceRegistryWithConsul(config.IPAddress, config.ServerPort, myUUID)

	fmt.Printf("Starting Hello Server: %v:%v", config.IPAddress, config.ServerPort)
	http.HandleFunc("/hello/api/v1", func(w http.ResponseWriter, r *http.Request) {
		hello.HelloHandler(w, r, myUUID)
	})

	http.HandleFunc("/health", hello.HealthHandler)
	http.ListenAndServe(":"+strconv.Itoa(config.ServerPort), nil)
}
