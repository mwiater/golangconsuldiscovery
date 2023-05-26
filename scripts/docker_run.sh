#!/bin/bash
#
# From root of project, run: `bash scripts/docker_run.sh`

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

if [ "$DOCKERIMAGE" = "" ]; then
  echo ""
  echo -e "${REDBOLD}Please set your DOCKERIMAGE environment variable in the .env file: ${RESET} E.g.: ${CYANBOLD}DOCKERIMAGE=mattwiater/golangconsuldiscovery${RESET}"
  echo ""
  exit 0
fi

if [ "$SERVERPORT" = "" ]; then
  echo ""
  echo -e "${REDBOLD}Please set your SERVERPORT environment variable in the .env file:${RESET} E.g.: ${CYANBOLD}SERVERPORT=5000${RESET}"
  echo ""
  exit 0
fi
if [ "$DOCKERPORT" = "" ]; then
  echo ""
  echo -e "${REDBOLD}Please set your DOCKERPORT environment variable in the .env file:${RESET} E.g.: ${CYANBOLD}DOCKERPORT=5000${RESET}"
  echo ""
  exit 0
fi

echo -e "${CYANBOLD}Running Docker container:${RESET} ${DOCKERIMAGE}${RESET}"
docker run -it -p $DOCKERPORT:$SERVERPORT --rm --name golangconsuldiscovery --hostname golangconsuldiscovery -e CONSUL_HTTP_ADDR=192.168.0.99:8500 -e FABIO_HTTP_ADDR=192.168.0.99:9999 $DOCKERIMAGE