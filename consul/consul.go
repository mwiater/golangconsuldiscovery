package consul

import (
	"fmt"
	"log"
	"os"
	"strconv"

	"github.com/google/uuid"
	"github.com/hashicorp/consul/api"
)

type ConsulClient struct {
	*api.Client
}

func ServiceRegistryWithConsul(ipAddress string, port int, myUUID uuid.UUID) {
	config := api.DefaultConfig()
	consul, err := api.NewClient(config)
	if err != nil {
		log.Println(err)
	}

	/* Each service instance should have an unique serviceID */
	serviceID := fmt.Sprintf("hello-%v", myUUID)
	/* Tag should follow the rule of Fabio: urlprefix- */
	tags := []string{"urlprefix-/hello/api/v1"}

	// DOCKERPORT: This is injected in the `docker run` command. It doesn't exist when the go app runs outside of a Docker container
	dockerContainerPort, _ := strconv.Atoi(os.Getenv("DOCKERPORT"))

	registration := &api.AgentServiceRegistration{
		ID:      serviceID,
		Name:    "hello-server",
		Port:    dockerContainerPort,
		Address: ipAddress,
		Tags:    tags, /* Add Tags for registration */
		Check: &api.AgentServiceCheck{
			HTTP:     fmt.Sprintf("http://%s:%v/health", ipAddress, dockerContainerPort),
			Interval: "10s",
			Timeout:  "30s",
		},
	}

	registrationErr := consul.Agent().ServiceRegister(registration)

	if registrationErr != nil {
		log.Printf("Failed to register service: %s:%v ", ipAddress, dockerContainerPort)
	} else {
		log.Printf("successfully register service: %s:%v", ipAddress, dockerContainerPort)
	}
}

func NewClient(addr string) (*ConsulClient, error) {
	conf := &api.Config{
		Address: addr,
	}
	client, err := api.NewClient(conf)
	if err != nil {
		log.Println("error initiating new consul client: ", err)
		return &ConsulClient{}, err
	}

	return &ConsulClient{
		client,
	}, nil
}
