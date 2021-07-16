#!/bin/bash

# for the STEAM_GSLT https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers
# for the STEAM_WEB_API_KEY https://developer.valvesoftware.com/wiki/CSGO_Workshop_For_Server_Operators

MAP_GROUP=$1
MAP_START=$2

rm -rf $ENV_CSGO_INSTALL_FOLDER/csgo/*.dem
rm -rf $ENV_CSGO_INSTALL_FOLDER/csgo/backup_round*.txt

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


maps=(
"ar_dizzy"
"de_pitstop"
"de_calavera"
"de_mocha"
"de_grind"
"ar_lunacy"
"ar_monastery"
"ar_shoots"
"cs_agency"
"cs_apollo"
"cs_assault"
"cs_italy"
"cs_militia"
"cs_office"
"de_ancient"
"de_anubis"
"de_bank"
"de_cache"
"de_canals"
"de_cbble"
"de_dust2"
"de_elysion"
"de_engage"
"de_guard"
"de_inferno"
"de_lake"
"de_mirage"
"de_nuke"
"de_overpass"
"de_safehouse"
"de_shortdust"
"de_shortnuke"
"de_stmarc"
"de_sugarcane"
"de_train"
"de_vertigo"
"workshop/125786610/cs_backalley"
"workshop/129042069/cs_bank"
"workshop/600914785/cs_cruise"
"workshop/135827566/cs_estate"
"workshop/273415773/cs_hijack"
"workshop/127012360/cs_museum"
"workshop/206678373/cs_valley"
"workshop/600728667/de_aqueduct"
"workshop/320674385/de_arcade_v2"
"workshop/1561348377/de_aztec"
"workshop/1302060184/de_beerhouse"
"workshop/529733812/de_blast_beta02"
"workshop/2011784264/de_blossom"
"workshop/874801875/de_Codewise2"
"workshop/215971897/de_coldwater"
"workshop/1414531578/de_cornerwork"
"workshop/239672577/de_crown"
"workshop/1387732091/de_dst"
"workshop/2175304484/de_engage"
"workshop/401145257/de_fire"
"workshop/2105680462/de_firenze"
"workshop/1958745897/de_marine"
"workshop/221603249/de_marquis"
"workshop/2064064363/de_miracle"
"workshop/1978052734/de_mutiny"
"workshop/1587622126/de_pyramid"
"workshop/546623875/de_santorini"
"workshop/1318698056/de_subzero"
"workshop/862889198/de_westwood2"
"workshop/1855652898/de_zenith"
"workshop/389175812/de_zoo"
"workshop/523638720/fy_simpsons"
"workshop/832164297/de_prodigy_classic"
)

for i in ${!maps[@]}; do
  echo "$i) ${maps[$i]}"
done


if [ -n "$2" ]; then
  echo "Start map specified as input param"
else
  #read -p "Choose the start map (type the number): "  startMap
  startMap=0
fi


echo ""
echo "You choose: ${maps[$startMap]}"
MAP_START=${maps[$startMap]}
echo ""

HOST_IP=$(hostname -I | awk '{print $1}')

steamcmd +login anonymous +force_install_dir $ENV_CSGO_INSTALL_FOLDER +app_update 740 +quit
$ENV_CSGO_INSTALL_FOLDER/srcds_run -game csgo -console -usercon -port 27015 +ip $HOST_IP +game_type 0 +game_mode 1 +mapgroup $MAP_GROUP +map $MAP_START -authkey $ENV_STEAM_API_KEY +sv_setsteamaccount $ENV_STEAM_CSGO_KEY -net_port_try 1

echo "End"

