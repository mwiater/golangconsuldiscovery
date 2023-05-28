# golangconsuldiscovery

## Article reference

This repository is a code companion to my article on Medium: **[Replicating and Load Balancing Go Applications in Docker Containers with Consul and Fabio](https://medium.com/@matt.wiater/replicating-and-load-balancing-go-applications-in-docker-containers-with-consul-and-fabio-3ec5eed15154)**. Please see that post for more details on this implementation.


## Application

### Quickstart

`make docker-run-consul-discovery`

```
Building Docker image:
  Docker build command: docker build -t mattwiater/golangconsuldiscovery .

[+] Building 9.1s (16/16) FINISHED
 => [internal] load build definition from Dockerfile                                                                                                                                                                                                                                                                    0.0s
 => => transferring dockerfile: 629B                                                                                                                                                                                                                                                                                    0.0s
 => [internal] load .dockerignore                                                                                                                                                                                                                                                                                       0.0s
 => => transferring context: 2B                                                                                                                                                                                                                                                                                         0.0s
 => [internal] load metadata for docker.io/library/alpine:latest                                                                                                                                                                                                                                                        0.4s
 => [internal] load metadata for docker.io/library/golang:alpine                                                                                                                                                                                                                                                        0.4s
 => [golangconsuldiscovery 1/6] FROM docker.io/library/golang:alpine@sha256:ee2f23f1a612da71b8a4cd78fec827f1e67b0a8546a98d257cca441a4ddbebcb                                                                                                                                                                            0.0s
 => => resolve docker.io/library/golang:alpine@sha256:ee2f23f1a612da71b8a4cd78fec827f1e67b0a8546a98d257cca441a4ddbebcb                                                                                                                                                                                                  0.0s
 => [internal] load build context                                                                                                                                                                                                                                                                                       0.0s
 => => transferring context: 9.84kB                                                                                                                                                                                                                                                                                     0.0s
 => FROM docker.io/library/alpine:latest@sha256:02bb6f428431fbc2809c5d1b41eab5a68350194fb508869a33cb1af4444c9b11                                                                                                                                                                                                        0.0s
 => CACHED [golangconsuldiscovery 2/6] RUN addgroup -S golangconsuldiscovery   && adduser -S -u 10000 -g golangconsuldiscovery golangconsuldiscovery                                                                                                                                                                    0.0s
 => CACHED [golangconsuldiscovery 3/6] WORKDIR /go/src/app                                                                                                                                                                                                                                                              0.0s
 => [golangconsuldiscovery 4/6] COPY . .                                                                                                                                                                                                                                                                                0.1s
 => [golangconsuldiscovery 5/6] RUN CGO_ENABLED=0 go install -ldflags '-extldflags "-static"' -tags timetzdata                                                                                                                                                                                                          8.0s
 => [golangconsuldiscovery 6/6] RUN echo ${PWD} && ls -lR                                                                                                                                                                                                                                                               0.5s
 => CACHED [stage-1 1/3] COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/                                                                                                                                                                                                                   0.0s
 => CACHED [stage-1 2/3] COPY --from=golangconsuldiscovery /go/bin/golangconsuldiscovery /golangconsuldiscovery                                                                                                                                                                                                         0.0s
 => CACHED [stage-1 3/3] COPY --from=golangconsuldiscovery /etc/passwd /etc/passwd                                                                                                                                                                                                                                      0.0s
 => exporting to image                                                                                                                                                                                                                                                                                                  0.0s
 => => exporting layers                                                                                                                                                                                                                                                                                                 0.0s
 => => writing image sha256:c6c87e044c0a6327c012db61039aeb47ac433b692df75862c3e06de20c9080c9                                                                                                                                                                                                                            0.0s
 => => naming to docker.io/mattwiater/golangconsuldiscovery                                                                                                                                                                                                                                                             0.0s

  Complete!

Starting Consul container:
  Docker run command: docker run -d --rm -p 8500:8500 -p 8600:8600/udp --name=golangconsuldiscovery-consul consul agent -server -ui -node=consul -bootstrap-expect=1 -client=0.0.0.0
  Complete!

Starting Fabio container:
  Docker run command: docker run -d --rm -p 9000:9000 -p 9001:9001 -v ./fabio.properties:/etc/fabio/fabio.properties --name=golangconsuldiscovery-fabiolb fabiolb/fabio
  Complete!

Starting hello app container instance 1/8:

  Starting Docker container: mattwiater/golangconsuldiscovery
  Container will forward its external port to the application port: 8001->8000
  Docker run command: docker run -d --rm  -p 8001:8000 --name golangconsuldiscovery-hello-1 -e DOCKERPORT=8001 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
  Complete!

Starting hello app container instance 2/8:

  Starting Docker container: mattwiater/golangconsuldiscovery
  Container will forward its external port to the application port: 8002->8000
  Docker run command: docker run -d --rm  -p 8002:8000 --name golangconsuldiscovery-hello-2 -e DOCKERPORT=8002 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
  Complete!

Starting hello app container instance 3/8:

  Starting Docker container: mattwiater/golangconsuldiscovery
  Container will forward its external port to the application port: 8003->8000
  Docker run command: docker run -d --rm  -p 8003:8000 --name golangconsuldiscovery-hello-3 -e DOCKERPORT=8003 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
  Complete!

Starting hello app container instance 4/8:

  Starting Docker container: mattwiater/golangconsuldiscovery
  Container will forward its external port to the application port: 8004->8000
  Docker run command: docker run -d --rm  -p 8004:8000 --name golangconsuldiscovery-hello-4 -e DOCKERPORT=8004 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
  Complete!

Starting hello app container instance 5/8:

  Starting Docker container: mattwiater/golangconsuldiscovery
  Container will forward its external port to the application port: 8005->8000
  Docker run command: docker run -d --rm  -p 8005:8000 --name golangconsuldiscovery-hello-5 -e DOCKERPORT=8005 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
  Complete!

Starting hello app container instance 6/8:

  Starting Docker container: mattwiater/golangconsuldiscovery
  Container will forward its external port to the application port: 8006->8000
  Docker run command: docker run -d --rm  -p 8006:8000 --name golangconsuldiscovery-hello-6 -e DOCKERPORT=8006 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
  Complete!

Starting hello app container instance 7/8:

  Starting Docker container: mattwiater/golangconsuldiscovery
  Container will forward its external port to the application port: 8007->8000
  Docker run command: docker run -d --rm  -p 8007:8000 --name golangconsuldiscovery-hello-7 -e DOCKERPORT=8007 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
  Complete!

Starting hello app container instance 8/8:

  Starting Docker container: mattwiater/golangconsuldiscovery
  Container will forward its external port to the application port: 8008->8000
  Docker run command: docker run -d --rm  -p 8008:8000 --name golangconsuldiscovery-hello-8 -e DOCKERPORT=8008 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
  Complete!

25cf15cf01c1   mattwiater/golangconsuldiscovery   "/golangconsuldiscov…"   Less than a second ago   Up Less than a second   0.0.0.0:8008->8000/tcp, :::8008->8000/tcp                                                                                      golangconsuldiscovery-hello-8
2934ccbade8a   mattwiater/golangconsuldiscovery   "/golangconsuldiscov…"   1 second ago             Up Less than a second   0.0.0.0:8007->8000/tcp, :::8007->8000/tcp                                                                                      golangconsuldiscovery-hello-7
ede6fbd4e796   mattwiater/golangconsuldiscovery   "/golangconsuldiscov…"   1 second ago             Up Less than a second   0.0.0.0:8006->8000/tcp, :::8006->8000/tcp                                                                                      golangconsuldiscovery-hello-6
b626b33b2eb1   mattwiater/golangconsuldiscovery   "/golangconsuldiscov…"   1 second ago             Up 1 second             0.0.0.0:8005->8000/tcp, :::8005->8000/tcp                                                                                      golangconsuldiscovery-hello-5
5e72d8ae1c7d   mattwiater/golangconsuldiscovery   "/golangconsuldiscov…"   2 seconds ago            Up 1 second             0.0.0.0:8004->8000/tcp, :::8004->8000/tcp                                                                                      golangconsuldiscovery-hello-4
a05747f73613   mattwiater/golangconsuldiscovery   "/golangconsuldiscov…"   2 seconds ago            Up 1 second             0.0.0.0:8003->8000/tcp, :::8003->8000/tcp                                                                                      golangconsuldiscovery-hello-3
6ca922bf2e29   mattwiater/golangconsuldiscovery   "/golangconsuldiscov…"   2 seconds ago            Up 2 seconds            0.0.0.0:8002->8000/tcp, :::8002->8000/tcp                                                                                      golangconsuldiscovery-hello-2
bb6083c319aa   mattwiater/golangconsuldiscovery   "/golangconsuldiscov…"   3 seconds ago            Up 2 seconds            0.0.0.0:8001->8000/tcp, :::8001->8000/tcp                                                                                      golangconsuldiscovery-hello-1
2f0d4fb5b23e   fabiolb/fabio                      "/usr/bin/fabio -cfg…"   3 seconds ago            Up 2 seconds            0.0.0.0:9000-9001->9000-9001/tcp, :::9000-9001->9000-9001/tcp, 9998-9999/tcp                                                   golangconsuldiscovery-fabiolb
366f53a2e74f   consul                             "docker-entrypoint.s…"   3 seconds ago            Up 3 seconds            8300-8302/tcp, 8600/tcp, 8301-8302/udp, 0.0.0.0:8500->8500/tcp, :::8500->8500/tcp, 0.0.0.0:8600->8600/udp, :::8600->8600/udp   golangconsuldiscovery-consul

Complete!

Dashboards may take a few seconds to come on line:
  Console Dashboard is avaiable:   http://192.168.0.99:8500/ui/dc1/services
  Fabio Dashboard is avaiable:     http://192.168.0.99:9001/routes
  Fabio Load Balanced Endpoint is: http://192.168.0.99:9000/hello/api/v1
```

### Teardown

`make docker-teardown-consul-discovery`

# Load testing: Ddosify

## Setup

### Install Docker-compose

`sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose`

`sudo chmod +x /usr/local/bin/docker-compose`

`/usr/local/bin/docker-compose version`

### Ddosify Self-hosted

Ref: https://github.com/ddosify/ddosify/tree/master/selfhosted


`git clone https://github.com/ddosify/ddosify.git`

`cd ddosify/selfhosted`

### Ddosify: Start

`docker-compose up -d`

The dashboard will be available, e.g.: http://192.168.0.99:8014

### Ddosify: Teardown

`docker compose down --volumes`

## RESULTS

```
1 Container Replica
-------------------
Total Requests:  6,000
Request Success: 233
Request Fail:    5,767
Avg:             2,840 (ms)
Min:             7 (ms)
Max:             9,933 (ms)

4 Container Replicas
--------------------
Total Requests:  6,000
Request Success: 5,796
Request Fail:    204
Avg:             290 (ms)
Min:             5 (ms)
Max:             9,873 (ms)

8 Container Replicas
--------------------
Total Requests:  6,000
Request Success: 6,000
Request Fail:    0
Avg:             17 (ms)
Min:             5 (ms)
Max:             86 (ms)
```