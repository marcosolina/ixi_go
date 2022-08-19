#!/bin/bash

# for the STEAM_GSLT https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers
# for the STEAM_WEB_API_KEY https://developer.valvesoftware.com/wiki/CSGO_Workshop_For_Server_Operators

MAP_GROUP=$1
MAP_START=$2

#rm -rf $ENV_CSGO_INSTALL_FOLDER/csgo/*.dem
rm -rf $ENV_CSGO_INSTALL_FOLDER/csgo/backup_round*.txt

# Preparing the file that is going to be used by
# the Java Helper Service
EVENT_FILE=$ENV_CSGO_INSTALL_FOLDER/csgo/addons/sourcemod/event.txt
echo "NO" > $EVENT_FILE

echo ""
echo ""
echo "   ____ ____    ____  ___    ____           _ _           _           _   ____                           "
echo "  / ___/ ___|_ / ___|/ _ \  |  _ \  ___  __| (_) ___ __ _| |_ ___  __| | / ___|  ___ _ ____   _____ _ __ "
echo " | |   \___ (_) |  _| | | | | | | |/ _ \/ _' | |/ __/ _' | __/ _ \/ _' | \___ \ / _ \ '__\ \ / / _ \ '__|"
echo " | |___ ___) || |_| | |_| | | |_| |  __/ (_| | | (_| (_| | ||  __/ (_| |  ___) |  __/ |   \ V /  __/ |   "
echo "  \____|____(_)\____|\___/  |____/ \___|\__,_|_|\___\__,_|\__\___|\__,_| |____/ \___|_|    \_/ \___|_|   "
echo ""
echo ""
echo ""        
echo ""

mapsGroup=(
  "mg_ixico_maps"
  "mg_workshop_maps"
  "mg_all_maps"
  "mg_short_maps"
  "mg_classic_maps"
)

for i in ${!mapsGroup[@]}; do
  echo "$i) ${mapsGroup[$i]}"
done


if [ -n "$1" ]; then
  echo "Start group provided as intput parameter"
else
  #read -p "Choose the start map group (type the number): " startGroup
  startGroup=0
fi

echo ""
echo "You choose: ${mapsGroup[$startGroup]}"
MAP_GROUP=${mapsGroup[$startGroup]}
echo ""

# Some small maps to be used as "starting map".
# Use a small map while we wait for everybody to join
maps=(
"ar_dizzy"
"cs_militia"
"de_bank"
"de_lake"
"de_safehouse"
"de_stmarc"
)

for i in ${!maps[@]}; do
  echo "$i) ${maps[$i]}"
done


if [ -n "$2" ]; then
  echo "Start map specified as input param"
else
  #read -p "Choose the start map (type the number): "  startMaip
  arrSize=$((${#maps[@]} - 1))
  randomMapIndex=$(($RANDOM % $arrSize))
  startMap=$randomMapIndex
fi


echo ""
echo "You choose: ${maps[$startMap]}"
MAP_START=${maps[$startMap]}
echo ""

HOST_IP=$(hostname -I | awk '{print $1}')

steamcmd +login anonymous +force_install_dir $ENV_CSGO_INSTALL_FOLDER +app_update 740 +quit
$ENV_CSGO_INSTALL_FOLDER/srcds_run -game csgo -console -usercon -port 27015 +ip $HOST_IP +game_type 0 +game_mode 1 +mapgroup $MAP_GROUP +map $MAP_START -authkey $ENV_STEAM_API_KEY +sv_setsteamaccount $ENV_STEAM_CSGO_KEY -net_port_try 1

echo "End"

