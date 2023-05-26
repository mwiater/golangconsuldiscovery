package main

import (
	"embed"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/google/uuid"
	consulapi "github.com/hashicorp/consul/api"

	"github.com/mwiater/golangconsuldiscovery/config"
	"github.com/mwiater/golangconsuldiscovery/structs"
)

var myUUID = uuid.New()
var letters = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

//go:embed .env
var envVarsFile embed.FS

func init() {
	rand.Seed(time.Now().UnixNano())
}

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

	serviceRegistryWithConsul(config.IPAddress, config.ServerPort)
	fmt.Printf("Starting Hello Server: %v:%v", config.IPAddress, config.ServerPort)
	http.HandleFunc("/hello/api/v1", hello)
	http.HandleFunc("/health", health)
	http.ListenAndServe(":"+strconv.Itoa(config.ServerPort), nil)
}

func serviceRegistryWithConsul(ipAddress string, port int) {
	config := consulapi.DefaultConfig()
	consul, err := consulapi.NewClient(config)
	if err != nil {
		log.Println(err)
	}

	/* Each service instance should have an unique serviceID */
	serviceID := fmt.Sprintf("hello-%v", myUUID)
	/* Tag should follow the rule of Fabio: urlprefix- */
	tags := []string{"urlprefix-/hello/api/v1"}

	// DOCKERPORT This is injected in the `docker run` command. It doesn't exist when the go app runs.
	dockerContainerPort, _ := strconv.Atoi(os.Getenv("DOCKERPORT"))

	registration := &consulapi.AgentServiceRegistration{
		ID:      serviceID,
		Name:    "hello-server",
		Port:    dockerContainerPort,
		Address: ipAddress,
		Tags:    tags, /* Add Tags for registration */
		Check: &consulapi.AgentServiceCheck{
			HTTP:     fmt.Sprintf("http://%s:%v/health", ipAddress, dockerContainerPort),
			Interval: "10s",
			Timeout:  "30s",
		},
	}

	regiErr := consul.Agent().ServiceRegister(registration)

	if regiErr != nil {
		log.Printf("Failed to register service: %s:%v ", ipAddress, dockerContainerPort)
	} else {
		log.Printf("successfully register service: %s:%v", ipAddress, dockerContainerPort)
	}
}

func hello(w http.ResponseWriter, r *http.Request) {
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

func health(w http.ResponseWriter, r *http.Request) {
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
