#!/bin/bash

# load env variables
export BASH_ENV=/etc/bash.bashrc

STEAMAPPID=730
LOGGED_USER=marco
HOMEDIR="/home/${LOGGED_USER}"
CS2_DIR="${HOMEDIR}/cs2"
SERVER_HELPER_SCRIPT=$CS2_DIR/jars/startHelper.sh
STEAMCMDDIR="${HOMEDIR}/steamcmd"
SERVER_FILE="${CS2_DIR}/game/csgo/cfg/gamemode_competitive.cfg"

EVENT_DIR=$CS2_DIR/csgo/addons/sourcemod
EVENT_FILE=$EVENT_DIR/event.txt

mkdir -p $EVENT_DIR
echo "NO" > $EVENT_FILE

$SERVER_HELPER_SCRIPT start

HOST_IP=$(hostname -I | awk '{print $1}')

curl --location --request POST "https://marco.selfip.net/ixigoproxy/ixigo-event-dispatcher/eventsdispatcher/event" --header 'Content-Type: application/json' --data-raw "{\"event_name\": \"start_installing_csgo\"}"

${STEAMCMDDIR}/steamcmd.sh +force_install_dir "${CS2_DIR}" \
                                +login "${ENV_STEAM_USER}" "${ENV_STEAM_PASSW}"\
                                +app_update "${STEAMAPPID}" \
                                +quit

curl --location --request POST "https://marco.selfip.net/ixigoproxy/ixigo-event-dispatcher/eventsdispatcher/event" --header 'Content-Type: application/json' --data-raw "{\"event_name\": \"start_csgo\"}"

# Search and replace operation
sed -i '/^mp_defuser_allocation/d' $SERVER_FILE
sed -i '/^mp_free_armor/d' $SERVER_FILE
sed -i '/^mp_maxrounds/d' $SERVER_FILE

echo "mp_defuser_allocation 2" >> $SERVER_FILE
echo "mp_free_armor 2" >> $SERVER_FILE
echo "mp_maxrounds 15" >> $SERVER_FILE


$CS2_DIR/game/bin/linuxsteamrt64/cs2 -dedicated \
        -port 27015 \
        -console \
        -usercon \
        -secure \
        +tv_enable 1 \
        +tv_autorecord 1 \
        +ip $HOST_IP \
        +game_type 0 \
        +game_mode 1 \
        +mapgroup mg_active \
        +map de_inferno \
        +mp_maxrounds 15 \
        +mp_free_armor 2 \
        +sv_setsteamaccount $ENV_STEAM_CSGO_KEY \
        +host_workshop_map 3181655247
        

curl --location --request POST "https://marco.selfip.net/ixigoproxy/ixigo-event-dispatcher/eventsdispatcher/event" --header 'Content-Type: application/json' --data-raw "{\"event_name\": \"shutdown\"}"

# Give the service some time to
# process the last DEM file
echo "Wait for 60 seconds"
sleep 60

$SERVER_HELPER_SCRIPT stop

#sudo shutdown now