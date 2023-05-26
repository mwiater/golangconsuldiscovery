package consul

import (
	"log"

	"github.com/hashicorp/consul/api"
)

type ConsulClient struct {
	*api.Client
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

func (c *ConsulClient) Register(id string) error {
	check := &api.AgentServiceCheck{
		Interval: "30s",
		Timeout:  "60s",
		HTTP:     "http://app:8000/health",
	}
	serviceDefinition := &api.AgentServiceRegistration{
		ID:    id,
		Name:  id + "_ms",
		Tags:  []string{"microservice", "golang"},
		Check: check,
	}
	if err := c.Agent().ServiceRegister(serviceDefinition); err != nil {
		log.Println("error registering service: ", err)
	}

	return nil
}
