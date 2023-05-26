// Package config implements .env file application configuration
package config

import (
	"embed"
	"strconv"
	"strings"

	"github.com/mwiater/golangconsuldiscovery/common"
)

var EnvVarsFile embed.FS

var IPAddress string
var ServerPort int

// AppConfig returns a new decoded Config map from .env file variables or sets from defaults
func AppConfig() (map[string]string, error) {
	envVars, _ := EnvVarsFile.ReadFile(".env")
	lines := common.SplitStringLines(string(envVars))
	var envs = make(map[string]string)
	for _, line := range lines {
		keyValuePair := strings.Split(line, "=")
		envs[keyValuePair[0]] = keyValuePair[1]

		if keyValuePair[0] == "IPADDRESS" {
			if keyValuePair[1] == "" {
				IPAddress = "192.168.0.99"
			} else {
				IPAddress = keyValuePair[1]
			}
		}

		if keyValuePair[0] == "SERVERPORT" {
			if keyValuePair[1] == "" {
				ServerPort = 8080
			} else {
				ServerPort, _ = strconv.Atoi(keyValuePair[1])
			}
		}
	}
	return envs, nil
}
