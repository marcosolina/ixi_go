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

# Metamod stuff
GAMEINFO_FILE_PATH="${CS2_DIR}/game/csgo/gameinfo.gi"
STRING_TO_SEARCH='			Game	csgo/addons/metamod'
AFTER_STRING="			Game_LowViolence	csgo_lv // Perfect World content override"

# Enabling metamod
if ! grep -q "$STRING_TO_SEARCH" "$GAMEINFO_FILE_PATH"; then
    sed -i -e "\|$AFTER_STRING|a \\$STRING_TO_SEARCH" "$GAMEINFO_FILE_PATH"
fi

cd /tmp
git clone --branch main https://github.com/marcosolina/ixi_go.git
cp -r /tmp/ixi_go/addons "${CS2_DIR}/game/csgo"