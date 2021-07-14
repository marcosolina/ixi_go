#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Preparing the file that is going to be used by
# the Java Helper Service
EVENT_FILE=$ENV_CSGO_INSTALL_FOLDER/csgo/addons/sourcemod/event.txt
echo "NO" > $EVENT_FILE

# Start the Helper Service and the
# IxiGo game server
$SCRIPT_DIR/jars/startHelper.sh start
$SCRIPT_DIR/startIxigoServer.sh

# Send the shtdown event.
# This will tell to the Helper service
# that he can copy the last DEM file
# On the dem parser Rasp
curl --location --request POST "https://marco.selfip.net/ixigoproxy/ixigo-event-dispatcher/eventsdispatcher/event" --header 'Content-Type: application/json' --data-raw "{\"eventName\": \"shutdown\"}"

# Give to the service some time to
# process the last DEM file
echo "Wait for 60 seconds"
sleep 60

# All done, stop the helper
$SCRIPT_DIR/jars/startHelper.sh stop
