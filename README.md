# goloangconsulmesh

## Refs

* Service Mesh Native Integration for Go Applications: https://developer.hashicorp.com/consul/docs/connect/native/go
* Consul with Containers: https://developer.hashicorp.com/consul/tutorials/day-0/docker-container-agents
* Service registry and discovery in Golang Cloud-Native microservice with Consul and Docker: https://organicprogrammer.com/2020/11/16/golang-service-discovery-consul/
* Fabio Integration: https://organicprogrammer.com/2020/12/30/golang-load-balancing-fabio/
* Fabio Integration: https://medium.com/@wisegain/consul-registrator-fabio-integration-c068280710b9
* Fabio: https://github.com/fabiolb/fabio

## Docker

### 1: Start: Consul Server

```
docker run \
  -d \
  --rm \
  -p 8500:8500 \
  -p 8600:8600/udp \
  --name=consul \
  consul agent -server -ui -node=consul -bootstrap-expect=1 -client=0.0.0.0
```

From interactive log #=>

```
==> Starting Consul agent...
              Version: '1.15.2'
           Build Date: '2023-03-30 17:51:19 +0000 UTC'
              Node ID: '4d08a786-a80c-21a1-491b-0b3728d1bd5e'
            Node name: 'server-1'
           Datacenter: 'dc1' (Segment: '<all>')
               Server: true (Bootstrap: true)
          Client Addr: [0.0.0.0] (HTTP: 8500, HTTPS: -1, gRPC: -1, gRPC-TLS: 8503, DNS: 8600)
         Cluster Addr: 172.17.0.2 (LAN: 8301, WAN: 8302)
    Gossip Encryption: false
     Auto-Encrypt-TLS: false
            HTTPS TLS: Verify Incoming: false, Verify Outgoing: false, Min Version: TLSv1_2
             gRPC TLS: Verify Incoming: false, Min Version: TLSv1_2
     Internal RPC TLS: Verify Incoming: false, Verify Outgoing: false (Verify Hostname: false), Min Version: TLSv1_2
```

`docker ps` #=>

```
docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                                                                                                                          NAMES
7f1a1b9d2436   consul    "docker-entrypoint.s…"   4 seconds ago   Up 3 seconds   8300-8302/tcp, 8600/tcp, 8301-8302/udp, 0.0.0.0:8500->8500/tcp, :::8500->8500/tcp, 0.0.0.0:8600->8600/udp, :::8600->8600/udp   consulagent
```

`docker exec consulagent consul members` #=>

```
Node      Address          Status  Type    Build   Protocol  DC   Partition  Segment
server-1  172.17.0.2:8301  alive   server  1.15.2  2         dc1  default    <all>
```

Stop container: `docker stop consul`

Dashboard:

http://192.168.0.99:8500/ui/dc1/services

http://192.168.0.99:8500/ui/dc1/nodes/server-1/health-checks


### 2: Start: Fabio Load Balancer

```
docker run \
  -d \
  --rm \
  -p 9999:9999 \
  -p 9998:9998 \
  -v $PWD/fabio.properties:/etc/fabio/fabio.properties \
  --name=fabiolb \
  fabiolb/fabio
```

Fabio Routes: http://192.168.0.99:9998/routes

Stop container: `docker stop fabiolb`

### 3: Spin up multiple, load-balance servers:

`docker build -t mattwiater/golangconsuldiscovery .`

Start: Consul:

```
docker run \
  -d --rm \
  -p 8500:8500 \
  -p 8600:8600/udp \
  --name=consul \
  consul agent -server -ui -node=consul -bootstrap-expect=1 -client=0.0.0.0
```


Start: Fabio Load Balancer:
```
docker run \
  -d --rm \
  -p 9000:9000 \
  -p 9001:9001 \
  -v $PWD/fabio.properties:/etc/fabio/fabio.properties \
  --name=fabiolb \
  fabiolb/fabio
```

### 2 Hello Instances: Example

```
docker run \
  -d --rm \
  -p 8001:8000 \
  --name golangconsuldiscovery01 \
  --hostname golangconsuldiscovery01 \
  -e DOCKERPORT=8001 \
  -e CONSUL_HTTP_ADDR=192.168.0.99:8500 \
  -e FABIO_HTTP_ADDR=192.168.0.99:9000 \
  mattwiater/golangconsuldiscovery
```

```
docker run \
  -d --rm \
  -p 8002:8000 \
  --name golangconsuldiscovery02 \
  --hostname golangconsuldiscovery02 \
  -e DOCKERPORT=8002 \
  -e CONSUL_HTTP_ADDR=192.168.0.99:8500 \
  -e FABIO_HTTP_ADDR=192.168.0.99:9000 \
  mattwiater/golangconsuldiscovery
```

Need to write teardown script...

```
docker stop consul && \
  docker stop fabiolb && \
  docker stop golangconsuldiscovery01 && \
  docker stop golangconsuldiscovery02
```


### 8 Hello Instances: Example

```
docker run -d --rm -p 8001:8000 --name golangconsuldiscovery01 --hostname golangconsuldiscovery01 -e DOCKERPORT=8001 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
docker run -d --rm -p 8002:8000 --name golangconsuldiscovery02 --hostname golangconsuldiscovery02 -e DOCKERPORT=8002 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
docker run -d --rm -p 8003:8000 --name golangconsuldiscovery03 --hostname golangconsuldiscovery03 -e DOCKERPORT=8003 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
docker run -d --rm -p 8004:8000 --name golangconsuldiscovery04 --hostname golangconsuldiscovery04 -e DOCKERPORT=8004 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
docker run -d --rm -p 8005:8000 --name golangconsuldiscovery05 --hostname golangconsuldiscovery05 -e DOCKERPORT=8005 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
docker run -d --rm -p 8006:8000 --name golangconsuldiscovery06 --hostname golangconsuldiscovery06 -e DOCKERPORT=8006 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
docker run -d --rm -p 8007:8000 --name golangconsuldiscovery07 --hostname golangconsuldiscovery07 -e DOCKERPORT=8007 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
docker run -d --rm -p 8008:8000 --name golangconsuldiscovery08 --hostname golangconsuldiscovery08 -e DOCKERPORT=8008 -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9000 mattwiater/golangconsuldiscovery
```

```
docker stop consul && \
  docker stop fabiolb && \
  docker stop golangconsuldiscovery01 && \
  docker stop golangconsuldiscovery02 && \
  docker stop golangconsuldiscovery03 && \
  docker stop golangconsuldiscovery04 && \
  docker stop golangconsuldiscovery05 && \
  docker stop golangconsuldiscovery06 && \
  docker stop golangconsuldiscovery07 && \
  docker stop golangconsuldiscovery08
```

## Initial Test Results

### One Instance:

JOBNAME=HTTPJob
TOTALJOBCOUNT=2000

```
Summary Results: HTTPJob
+---------+------+--------------+-------------------+-------------+--------+
| WORKERS | JOBS | AVG JOB TIME | TOTAL WORKER TIME | AVG MEM USE |  +/-   |
+---------+------+--------------+-------------------+-------------+--------+
|       1 | 2000 | 0.01s        | 30.93s            | 0.355Mb     | (1x)*  |
|       2 | 2000 | 0.01s        | 25.84s            | 1.040Mb     | +1.2x  |
|       3 | 2000 | 0.01s        | 25.08s            | 1.748Mb     | +1.23x |
|       4 | 2000 | 0.02s        | 25.46s            | 2.438Mb     | +1.22x |
|       5 | 2000 | 0.02s        | 26.00s            | 3.128Mb     | +1.19x |
|       6 | 2000 | 0.02s        | 25.34s            | 3.827Mb     | +1.22x |
|       7 | 2000 | 0.03s        | 26.75s            | 4.518Mb     | +1.16x |
|       8 | 2000 | 0.03s        | 22.70s            | 5.237Mb     | +1.36x |
+---------+------+--------------+-------------------+-------------+--------+

* Baseline: All subsequent +/- tests are compared to this.
```

### 8 Instances

```
Summary Results: HTTPJob
+---------+------+--------------+-------------------+-------------+--------+
| WORKERS | JOBS | AVG JOB TIME | TOTAL WORKER TIME | AVG MEM USE |  +/-   |
+---------+------+--------------+-------------------+-------------+--------+
|       1 | 2000 | 0.01s        | 25.52s            | 0.354Mb     | (1x)*  |
|       2 | 2000 | 0.01s        | 23.12s            | 1.049Mb     | +1.1x  |
|       3 | 2000 | 0.01s        | 21.01s            | 1.747Mb     | +1.21x |
|       4 | 2000 | 0.01s        | 19.39s            | 2.436Mb     | +1.32x |
|       5 | 2000 | 0.01s        | 20.00s            | 3.124Mb     | +1.28x |
|       6 | 2000 | 0.01s        | 19.40s            | 3.822Mb     | +1.32x |
|       7 | 2000 | 0.01s        | 19.08s            | 4.521Mb     | +1.34x |
|       8 | 2000 | 0.02s        | 21.31s            | 5.223Mb     | +1.2x  |
+---------+------+--------------+-------------------+-------------+--------+

* Baseline: All subsequent +/- tests are compared to this.
```

## Load testing

REF:https://www.artillery.io/docs/guides/guides/command-line#examples

### 1 Instance (w/ 200k payload)

```
artillery quick \
    --count 1000 \
    --num 10 \
    http://192.168.0.99:9999/hello
```

```
All VUs finished. Total time: 21 seconds

--------------------------------
Summary report @ 14:12:56(-0700)
--------------------------------

errors.ETIMEDOUT: .............................................................. 1000
http.codes.200: ................................................................ 21
http.request_rate: ............................................................. 78/sec
http.requests: ................................................................. 1021
http.response_time:
  min: ......................................................................... 10
  max: ......................................................................... 9989
  median: ...................................................................... 5487.5
  p95: ......................................................................... 9801.2
  p99: ......................................................................... 9801.2
http.responses: ................................................................ 21
vusers.created: ................................................................ 1000
vusers.created_by_name.0: ...................................................... 1000
vusers.failed: ................................................................. 1000
```

### 4 Instances (w/ 200k payload)

```
artillery quick \
    --count 1000 \
    --num 10 \
    http://192.168.0.99:9999/hello
```

```
All VUs finished. Total time: 33 seconds

--------------------------------
Summary report @ 14:11:53(-0700)
--------------------------------

http.codes.200: ................................................................ 10000
http.request_rate: ............................................................. 326/sec
http.requests: ................................................................. 10000
http.response_time:
  min: ......................................................................... 5
  max: ......................................................................... 8024
  median: ...................................................................... 2671
  p95: ......................................................................... 5065.6
  p99: ......................................................................... 5944.6
http.responses: ................................................................ 10000
vusers.completed: .............................................................. 1000
vusers.created: ................................................................ 1000
vusers.created_by_name.0: ...................................................... 1000
vusers.failed: ................................................................. 0
vusers.session_length:
  min: ......................................................................... 10153
  max: ......................................................................... 30958.2
  median: ...................................................................... 27181.5
  p95: ......................................................................... 30040.3
  p99: ......................................................................... 30647.1
```

### 8 Instances (w/ 200k payload)

```
artillery quick \
    --count 1000 \
    --num 10 \
    http://192.168.0.99:9999/hello
```

```
All VUs finished. Total time: 19 seconds

--------------------------------
Summary report @ 14:10:10(-0700)
--------------------------------

http.codes.200: ................................................................ 10000
http.request_rate: ............................................................. 548/sec
http.requests: ................................................................. 10000
http.response_time:
  min: ......................................................................... 5
  max: ......................................................................... 8473
  median: ...................................................................... 1300.1
  p95: ......................................................................... 3605.5
  p99: ......................................................................... 4867
http.responses: ................................................................ 10000
vusers.completed: .............................................................. 1000
vusers.created: ................................................................ 1000
vusers.created_by_name.0: ...................................................... 1000
vusers.failed: ................................................................. 0
vusers.session_length:
  min: ......................................................................... 395.7
  max: ......................................................................... 17832.3
  median: ...................................................................... 15526
  p95: ......................................................................... 17158.9
  p99: ......................................................................... 17505.6
```