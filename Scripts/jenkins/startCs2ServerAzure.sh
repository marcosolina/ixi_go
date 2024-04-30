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

# Events stuff
EVENT_DIR=$CS2_DIR/game/bin/linuxsteamrt64
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

${HOMEDIR}/installMetaModAndPlugin.sh

curl --location --request POST "https://marco.selfip.net/ixigoproxy/ixigo-event-dispatcher/eventsdispatcher/event" --header 'Content-Type: application/json' --data-raw "{\"event_name\": \"start_csgo\"}"
curl --location --request POST 'https://marco.selfip.net/ixigoproxy/ixigo-dem-manager/demmanager/parse/failed'

# Search and replace operation
sed -i '/^mp_defuser_allocation/d' $SERVER_FILE
sed -i '/^mp_free_armor/d' $SERVER_FILE
sed -i '/^mp_maxrounds/d' $SERVER_FILE

echo "mp_defuser_allocation 2" >> $SERVER_FILE
echo "mp_free_armor 2" >> $SERVER_FILE
echo "mp_maxrounds 15" >> $SERVER_FILE

# List of maps
workshop_maps=(
3070290240
3070293560
3070550406
3070562370
3070563536
3070581293
3070584943
3070593234
3070594412
3070612859
3070766070
3070852091
3071005299
3071899764
3075706807
3077752384
3084661017
3085200029
3085490518
3095875614
3100864853
3108198185
3114023815
3121051997
3121217565
3127729110
3132854332
3150246494
3157804628
3165559377
3181655247
3195399109
)

# Get a random map from the list
random_map=${workshop_maps[$RANDOM % ${#workshop_maps[@]}]}


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
        +host_workshop_map 3070290240 \
        +host_workshop_map 3070293560 \
        +host_workshop_map 3070550406 \
        +host_workshop_map 3070562370 \
        +host_workshop_map 3070563536 \
        +host_workshop_map 3070581293 \
        +host_workshop_map 3070584943 \
        +host_workshop_map 3070593234 \
        +host_workshop_map 3070594412 \
        +host_workshop_map 3070612859 \
        +host_workshop_map 3070766070 \
        +host_workshop_map 3070852091 \
        +host_workshop_map 3071005299 \
        +host_workshop_map 3071899764 \
        +host_workshop_map 3075706807 \
        +host_workshop_map 3077752384 \
        +host_workshop_map 3084661017 \
        +host_workshop_map 3085200029 \
        +host_workshop_map 3085490518 \
        +host_workshop_map 3095875614 \
        +host_workshop_map 3100864853 \
        +host_workshop_map 3108198185 \
        +host_workshop_map 3114023815 \
        +host_workshop_map 3121051997 \
        +host_workshop_map 3121217565 \
        +host_workshop_map 3127729110 \
        +host_workshop_map 3132854332 \
        +host_workshop_map 3150246494 \
        +host_workshop_map 3157804628 \
        +host_workshop_map 3165559377 \
        +host_workshop_map 3181655247 \
        +host_workshop_map 3195399109 \
        +host_workshop_map $random_map
        

#curl --location --request POST "https://marco.selfip.net/ixigoproxy/ixigo-event-dispatcher/eventsdispatcher/event" --header 'Content-Type: application/json' --data-raw "{\"event_name\": \"shutdown\"}"

# Give the service some time to
# process the last DEM file
#echo "Wait for 60 seconds"
#sleep 60

#$SERVER_HELPER_SCRIPT stop

# Reboot the server in case it has crashed
sudo reboot now