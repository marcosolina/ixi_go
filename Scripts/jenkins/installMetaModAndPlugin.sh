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
ADDONS_DIR="${CS2_DIR}/game/csgo/addons"

if [ -d "$ADDONS_DIR" ]; then
    echo "ADDONS_DIR already exists. Exiting..."
    exit 0
fi

# Metamod stuff
GAMEINFO_FILE_PATH="${CS2_DIR}/game/csgo/gameinfo.gi"
STRING_TO_SEARCH='			Game	csgo/addons/metamod'
AFTER_STRING="			Game_LowViolence	csgo_lv // Perfect World content override"

# Enabling metamod
if ! grep -q "$STRING_TO_SEARCH" "$GAMEINFO_FILE_PATH"; then
    sed -i -e "\|$AFTER_STRING|a \\$STRING_TO_SEARCH" "$GAMEINFO_FILE_PATH"
fi

cd /tmp

################################
# Download plugins and frameworks
################################
BASE_FOLDER=/tmp

##########################################################
# Download the latest version of CounterStrikeSharp plugin
##########################################################

CSS_URL="https://api.github.com/repos/roflmuffin/CounterStrikeSharp/releases/latest"
HTML=$(curl -s $CSS_URL)

# If I have the latest version, I can stop the script
ID=$(echo $HTML | jq -r '.id')
echo "The CS Sharp plugin id $ID"

# New version available, download the file
CSS_SHARP_FILE="$BASE_FOLDER/cssharp.zip"
ASSETS=$(echo $HTML | jq -r '.assets[] | select(.name | test("with-runtime.*linux")) | .browser_download_url')
for URL in $ASSETS; do
    curl -L -o "$CSS_SHARP_FILE" "$URL"
done

#########################################################
# Download the latest version of Metamod plugin framework
#########################################################
URL="https://www.sourcemm.net/downloads.php?branch=dev"

# Fetch HTML content
HTML=$(curl -s $URL)

# Extract download link
FILE_URL=$(echo $HTML | grep -oP "(?<=href=')[^']*linux.tar.gz")

FILE_URL=$(echo $FILE_URL | awk '{print $1}')

META_MODE_FILE="$BASE_FOLDER/metamod.tar.gz"

# Download the file
curl -L -o "$META_MODE_FILE" "$FILE_URL"

########################################################
# Extract metamod and CounterStrikeSharp plugin files
# and merge them into the destination directory
########################################################
CSS_SHARP_UNZIP_DIR="$BASE_FOLDER/cssharp"
# Extract the files
tar -xf "$META_MODE_FILE" -C "$BASE_FOLDER"
unzip -o "$CSS_SHARP_FILE" -d "$CSS_SHARP_UNZIP_DIR"

# Merge directories if they exist
SOURCE_DIR="$CSS_SHARP_UNZIP_DIR/addons"
DESTINATION_DIR="$BASE_FOLDER/addons"

mkdir -p "$DESTINATION_DIR"
cp -r "$SOURCE_DIR/"* "$DESTINATION_DIR/"

#################################################
# Clone the repo that contains the CSSharp plugin
#################################################
CSGO_UTIL_DIR="$BASE_FOLDER/csgo_util"
git clone "https://github.com/marcosolina/csgo_util.git" "$CSGO_UTIL_DIR"
IXIGO_PLUGIN_DIR="$CSGO_UTIL_DIR/CsgoPlugins/IxigoPlugin"
IXIGO_PLUGIN_BIN_DIR="$CSGO_UTIL_DIR/CsgoPlugins/IxigoPlugin/bin/Debug/net8.0"

# Build the plugin
dotnet add "$IXIGO_PLUGIN_DIR" package CounterStrikeSharp.API
dotnet clean "$IXIGO_PLUGIN_DIR"
dotnet build "$IXIGO_PLUGIN_DIR"

# Copy the plugin to the destination directory
CSS_SHARP_DIRECTORY_PLUGINS="$DESTINATION_DIR/counterstrikesharp/plugins"
IXIGO_PLUGIN_DIR="$CSS_SHARP_DIRECTORY_PLUGINS/IxigoPlugin"
mkdir -p "$IXIGO_PLUGIN_DIR"
cp -r "$IXIGO_PLUGIN_BIN_DIR/"* "$IXIGO_PLUGIN_DIR/"



sudo chown $LOGGED_USER:$LOGGED_USER -R $DESTINATION_DIR
sudo chmod 766 -R $DESTINATION_DIR

sudo cp -r $DESTINATION_DIR "${CS2_DIR}/game/csgo"

sudo chown $LOGGED_USER:$LOGGED_USER -R $ADDONS_DIR
sudo chmod 766 -R $ADDONS_DIR