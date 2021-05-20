#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

EVENT_FILE=$ENV_CSGO_INSTALL_FOLDER/csgo/addons/sourcemod/event.txt
echo "NO" > $EVENT_FILE

$SCRIPT_DIR/startHelper.sh start
nohup $SCRIPT_DIR/startEventsMonitor.sh >> /tmp/eventMonitor.log 2&1&
$SCRIPT_DIR/startIxigoServer.sh

curl --location --request POST "http://$ENV_SSH_IP:8763/zuul/csgo-rest-api/rcon/event" --header 'Content-Type: application/json' --data-raw "{\"eventName\": \"shutdown\"}"

echo "Wait for 60 seconds"
sleep 60

$SCRIPT_DIR/startHelper.sh stop

