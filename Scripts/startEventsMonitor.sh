#!/bin/bash

OLD_VALUE="NO"

CSGO_INSTALL_FOLDER_FOLDER=$ENV_CSGO_INSTALL_FOLDER
EVENT_FILE=$ENV_CSGO_INSTALL_FOLDER/csgo/addons/sourcemod/event.txt

echo "NO" > $EVENT_FILE

DATE=$(date +'%Y-%m-%d')
FOLDER_DEM="$ENV_SSH_FOLDER/demfiles/$DATE"


while :
do
        NEW_VALUE=$(tr -d '\n' < $EVENT_FILE)
        if [ "$OLD_VALUE" = "$NEW_VALUE" ]; then
                # echo "equal"
                DUMMY=ciao
        else
                OLD_VALUE="NO"
                echo "sending event $NEW_VALUE"
                echo "NO" > $EVENT_FILE
                curl --location --request POST "http://$ENV_SSH_IP:8763/zuul/csgo-rest-api/rcon/event" --header 'Content-Type: application/json' --data-raw "{\"eventName\": \"$NEW_VALUE\"}"
        fi

        sleep 1
done

