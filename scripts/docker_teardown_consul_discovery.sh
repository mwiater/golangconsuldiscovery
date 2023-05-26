#!/bin/bash
#
# From root of project, run: `bash scripts/docker_teardown_consul_discovery.sh`

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

echo ""
echo -e "${CYANBOLD}Stopping all golangconsuldiscovery containers:${RESET}"
echo -e "  Docker stop command: ${GREENBOLD}docker stop \$(docker ps | grep golangconsuldiscovery- | awk '{print \$1}')${RESET}"
echo ""
echo ""

ERROR=$(docker stop $(docker ps | grep golangconsuldiscovery- | awk '{print $1}') 2>&1 1>/dev/null)
status=$?
if test $status -ne 0
then
	echo -e "${CYANBOLD}  No containers found to stop.${RESET}"
  echo ""
  exit 0
fi

echo ""
docker ps
echo ""
echo -e "${GREENBOLD}Complete!${RESET}"
echo ""