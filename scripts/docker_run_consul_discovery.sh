#!/bin/bash
#
# From root of project, run: `bash scripts/docker_run_consul_discovery.sh`

clear

if [ ! -f ../.env ]
then
  export $(cat .env | xargs)
fi

# Color Console Output
RESET='\033[0m'           # Text Reset
REDBOLD='\033[1;31m'      # Red (Bold)
GREENBOLD='\033[1;32m'    # Green (Bold)
YELLOWBOLD='\033[1;33m'   # Yellow (Bold)
CYANBOLD='\033[1;36m'     # Cyan (Bold)

if [ "$IPADDRESS" = "" ]; then
  echo ""
  echo -e "${REDBOLD}Please set your IPADDRESS environment variable in the .env file: ${RESET} E.g.: ${CYANBOLD}IPADDRESS=192.168.0.99${RESET}"
  echo ""
  exit 0
fi

if [ "$DOCKERIMAGE" = "" ]; then
  echo ""
  echo -e "${REDBOLD}Please set your DOCKERIMAGE environment variable in the .env file: ${RESET} E.g.: ${CYANBOLD}DOCKERIMAGE=mattwiater/golangconsuldiscovery${RESET}"
  echo ""
  exit 0
fi

if [ "$SERVERPORT" = "" ]; then
  echo ""
  echo -e "${REDBOLD}Please set your SERVERPORT environment variable in the .env file:${RESET} E.g.: ${CYANBOLD}SERVERPORT=8000${RESET}"
  echo ""
  exit 0
fi

if [ "$DOCKERPORT" = "" ]; then
  echo ""
  echo -e "${REDBOLD}Please set your DOCKERPORT environment variable in the .env file:${RESET} E.g.: ${CYANBOLD}DOCKERPORT=8001${RESET}"
  echo ""
  exit 0
fi

if [ "$CONSUL_HTTP_PORT" = "" ]; then
  echo ""
  echo -e "${REDBOLD}Please set your CONSUL_HTTP_PORT environment variable in the .env file:${RESET} E.g.: ${CYANBOLD}CONSUL_HTTP_PORT=8500${RESET}"
  echo ""
  exit 0
fi

if [ "$FABIO_HTTP_PORT" = "" ]; then
  echo ""
  echo -e "${REDBOLD}Please set your FABIO_HTTP_PORT environment variable in the .env file:${RESET} E.g.: ${CYANBOLD}FABIO_HTTP_PORT=9000${RESET}"
  echo ""
  exit 0
fi

if [ "$FABIO_DASHBOARD_PORT" = "" ]; then
  echo ""
  echo -e "${REDBOLD}Please set your FABIO_DASHBOARD_PORT environment variable in the .env file:${RESET} E.g.: ${CYANBOLD}FABIO_DASHBOARD_PORT=9001${RESET}"
  echo ""
  exit 0
fi

if [ "$NUMBER_OF_INSTANCES" = "" ]; then
  echo ""
  echo -e "${REDBOLD}Please set your NUMBER_OF_INSTANCES environment variable in the .env file: ${RESET} E.g.: ${CYANBOLD}NUMBER_OF_INSTANCES=8${RESET}"
  echo ""
  exit 0
fi

echo -e "${CYANBOLD}Building Docker image:${RESET}"
echo -e "  Docker build command: ${GREENBOLD}docker build -t ${DOCKERIMAGE} .${RESET}"
echo ""
docker build -t ${DOCKERIMAGE} .
echo ""
echo -e "  ${GREENBOLD}Complete!${RESET}"
echo ""

echo -e "${CYANBOLD}Starting Consul container:${RESET}"
echo -e "  Docker run command: ${GREENBOLD}docker run -d --rm -p ${CONSUL_HTTP_PORT}:${CONSUL_HTTP_PORT} -p 8600:8600/udp --name=golangconsuldiscovery-consul consul agent -server -ui -node=consul -bootstrap-expect=1 -client=0.0.0.0${RESET}"
docker run -d --rm -p ${CONSUL_HTTP_PORT}:${CONSUL_HTTP_PORT} -p 8600:8600/udp --name=golangconsuldiscovery-consul consul agent -server -ui -node=consul -bootstrap-expect=1 -client=0.0.0.0 2>&1 1>/dev/null
echo -e "  ${GREENBOLD}Complete!${RESET}"
echo ""

echo -e "${CYANBOLD}Starting Fabio container:${RESET}"
echo -e "  Docker run command: ${GREENBOLD}docker run -d --rm -p ${FABIO_HTTP_PORT}:${FABIO_HTTP_PORT} -p ${FABIO_DASHBOARD_PORT}:${FABIO_DASHBOARD_PORT} -v ./fabio.properties:/etc/fabio/fabio.properties --name=golangconsuldiscovery-fabiolb fabiolb/fabio${RESET}"
docker run -d --rm -p ${FABIO_HTTP_PORT}:${FABIO_HTTP_PORT} -p ${FABIO_DASHBOARD_PORT}:${FABIO_DASHBOARD_PORT} -v ./fabio.properties:/etc/fabio/fabio.properties --name=golangconsuldiscovery-fabiolb fabiolb/fabio 2>&1 1>/dev/null
echo -e "  ${GREENBOLD}Complete!${RESET}"
echo ""


DYNAMIC_DOCKER_PORT=${DOCKERPORT}
for (( INSTANCE=1; INSTANCE<=NUMBER_OF_INSTANCES; INSTANCE++ ))
do 
  echo -e "${CYANBOLD}Starting hello app container instance ${INSTANCE}/${NUMBER_OF_INSTANCES}:${RESET}"
  echo ""
  echo -e "  ${CYANBOLD}Starting Docker container:${RESET} ${GREENBOLD}${DOCKERIMAGE}${RESET}"
  echo -e "  Container will forward its external port to the application port: ${GREENBOLD}${DYNAMIC_DOCKER_PORT}->${SERVERPORT}${RESET}"
  echo -e "  Docker run command: ${GREENBOLD}docker run -d --rm  -p $DYNAMIC_DOCKER_PORT:$SERVERPORT --name golangconsuldiscovery-hello-${INSTANCE} -e DOCKERPORT=${DYNAMIC_DOCKER_PORT} -e CONSUL_HTTP_ADDR=${IPADDRESS}:${CONSUL_HTTP_PORT} -e FABIO_HTTP_ADDR=${IPADDRESS}:${FABIO_HTTP_PORT} $DOCKERIMAGE${RESET}"
  docker run -d --rm  -p $DYNAMIC_DOCKER_PORT:$SERVERPORT --name golangconsuldiscovery-hello-${INSTANCE} -e DOCKERPORT=${DYNAMIC_DOCKER_PORT} -e CONSUL_HTTP_ADDR=${IPADDRESS}:${CONSUL_HTTP_PORT} -e FABIO_HTTP_ADDR=${IPADDRESS}:${FABIO_HTTP_PORT} $DOCKERIMAGE 2>&1 1>/dev/null
  echo -e "  ${GREENBOLD}Complete!${RESET}"
  echo ""
  ((DYNAMIC_DOCKER_PORT=DYNAMIC_DOCKER_PORT+1))
done

echo ""
docker ps | grep golangconsuldiscovery-
echo ""
echo -e "${GREENBOLD}Complete!${RESET}"
echo ""

echo -e "${CYANBOLD}Dashboards may take a few seconds to come on line:${RESET}"
echo -e "  ${CYANBOLD}Console Dashboard is avaiable:${RESET}   http://${IPADDRESS}:${CONSUL_HTTP_PORT}/ui/dc1/services ${RESET}"
echo -e "  ${CYANBOLD}Fabio Dashboard is avaiable:${RESET}     http://${IPADDRESS}:${FABIO_DASHBOARD_PORT}/routes ${RESET}"
echo -e "  ${CYANBOLD}Fabio Load Balanced Endpoint is:${RESET} http://${IPADDRESS}:${FABIO_HTTP_PORT}/hello/api/v1 ${RESET}"
echo ""
echo ""
