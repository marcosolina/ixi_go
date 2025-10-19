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

# Force a clean CS2 installation to ensure all libraries are present
echo "Updating CS2 server files..."
${STEAMCMDDIR}/steamcmd.sh +force_install_dir "${CS2_DIR}" \
                                +login "${ENV_STEAM_USER}" "${ENV_STEAM_PASSW}"\
                                +app_update "${STEAMAPPID}" validate \
                                +quit

# Check if libserver_valve.so exists, if not, try to restore it
LIBSERVER_PATH="${CS2_DIR}/game/bin/linuxsteamrt64/libserver_valve.so"
if [ ! -f "$LIBSERVER_PATH" ]; then
    echo "libserver_valve.so is missing. Attempting to restore..."
    
    # Try to find a backup or copy from another location
    POSSIBLE_LOCATIONS=(
        "${CS2_DIR}/game/csgo/bin/linuxsteamrt64/libserver.so"
        "${CS2_DIR}/game/bin/linuxsteamrt64/libserver.so"
    )
    
    for location in "${POSSIBLE_LOCATIONS[@]}"; do
        if [ -f "$location" ]; then
            echo "Found server library at $location, creating symlink..."
            ln -sf "$location" "$LIBSERVER_PATH"
            break
        fi
    done
    
    # If still missing, we need to disable MetaMod temporarily
    if [ ! -f "$LIBSERVER_PATH" ]; then
        echo "WARNING: libserver_valve.so still missing. Disabling MetaMod for this run..."
        DISABLE_METAMOD=true
    fi
fi

# Install MetaMod and plugins only if not disabled
if [ "$DISABLE_METAMOD" != "true" ]; then
    ${HOMEDIR}/installMetaModAndPlugin.sh
else
    echo "Skipping MetaMod installation due to missing server library"
fi

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
3127729110
3132854332
3150246494
3157804628
3181655247
3195399109
)

# Get a random map from the list
random_map=${workshop_maps[$RANDOM % ${#workshop_maps[@]}]}

# Set library path to help with loading issues
export LD_LIBRARY_PATH="${CS2_DIR}/game/bin/linuxsteamrt64:$LD_LIBRARY_PATH"

# Add error handling and logging
echo "Starting CS2 server with the following configuration:"
echo "CS2_DIR: $CS2_DIR"
echo "HOST_IP: $HOST_IP"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"

# Check if the cs2 binary exists and is executable
CS2_BINARY="$CS2_DIR/game/bin/linuxsteamrt64/cs2"
if [ ! -f "$CS2_BINARY" ]; then
    echo "ERROR: CS2 binary not found at $CS2_BINARY"
    exit 1
fi

if [ ! -x "$CS2_BINARY" ]; then
    echo "Making CS2 binary executable..."
    chmod +x "$CS2_BINARY"
fi

# Start the server with error handling
echo "Launching CS2 server..."
"$CS2_BINARY" -dedicated \
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
        +sv_setsteamaccount $ENV_STEAM_CSGO_KEY

# Capture the exit code
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "CS2 server exited with code: $EXIT_CODE"
    
    # If it's a segmentation fault, try without MetaMod
    if [ $EXIT_CODE -eq 139 ] && [ "$DISABLE_METAMOD" != "true" ]; then
        echo "Segmentation fault detected. Trying to start without MetaMod..."
        
        # Temporarily disable MetaMod by renaming the addons directory
        if [ -d "${CS2_DIR}/game/csgo/addons" ]; then
            mv "${CS2_DIR}/game/csgo/addons" "${CS2_DIR}/game/csgo/addons.disabled"
        fi
        
        # Try starting again
        "$CS2_BINARY" -dedicated \
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
                +sv_setsteamaccount $ENV_STEAM_CSGO_KEY
    fi
fi

#curl --location --request POST "https://marco.selfip.net/ixigoproxy/ixigo-event-dispatcher/eventsdispatcher/event" --header 'Content-Type: application/json' --data-raw "{\"event_name\": \"shutdown\"}"

# Give the service some time to
# process the last DEM file
#echo "Wait for 60 seconds"
#sleep 60

#$SERVER_HELPER_SCRIPT stop

# Reboot the server in case it has crashed
#sudo reboot now