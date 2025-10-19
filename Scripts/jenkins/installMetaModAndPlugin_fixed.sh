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

# Check if CS2 server files are properly installed
LIBSERVER_VALVE="${CS2_DIR}/game/bin/linuxsteamrt64/libserver_valve.so"
LIBSERVER="${CS2_DIR}/game/bin/linuxsteamrt64/libserver.so"

echo "Checking CS2 server installation..."

# Verify critical server files exist
if [ ! -f "${CS2_DIR}/game/bin/linuxsteamrt64/cs2" ]; then
    echo "ERROR: CS2 binary not found. Please ensure CS2 is properly installed."
    exit 1
fi

# Handle missing libserver_valve.so
if [ ! -f "$LIBSERVER_VALVE" ]; then
    echo "WARNING: libserver_valve.so is missing."
    
    # Try to find and backup the original server library
    if [ -f "$LIBSERVER" ]; then
        echo "Backing up original libserver.so..."
        cp "$LIBSERVER" "${LIBSERVER}.backup"
        echo "Creating symlink for libserver_valve.so..."
        ln -sf "$LIBSERVER" "$LIBSERVER_VALVE"
    else
        echo "ERROR: Both libserver_valve.so and libserver.so are missing."
        echo "Please verify your CS2 installation with: steamcmd +app_update 730 validate +quit"
        exit 1
    fi
fi

if [ -d "$ADDONS_DIR" ]; then
    echo "ADDONS_DIR already exists. Checking for updates..."
    # Instead of exiting, we'll update the existing installation
    FORCE_UPDATE=true
else
    FORCE_UPDATE=false
fi

# Metamod stuff
GAMEINFO_FILE_PATH="${CS2_DIR}/game/csgo/gameinfo.gi"
STRING_TO_SEARCH='			Game	csgo/addons/metamod'
AFTER_STRING="			Game_LowViolence	csgo_lv // Perfect World content override"

# Backup gameinfo.gi before modifying
if [ ! -f "${GAMEINFO_FILE_PATH}.backup" ]; then
    cp "$GAMEINFO_FILE_PATH" "${GAMEINFO_FILE_PATH}.backup"
    echo "Backed up gameinfo.gi"
fi

# Enabling metamod
if ! grep -q "$STRING_TO_SEARCH" "$GAMEINFO_FILE_PATH"; then
    echo "Adding MetaMod to gameinfo.gi..."
    sed -i -e "\|$AFTER_STRING|a \\$STRING_TO_SEARCH" "$GAMEINFO_FILE_PATH"
else
    echo "MetaMod already enabled in gameinfo.gi"
fi

cd /tmp

################################
# Download plugins and frameworks
################################
BASE_FOLDER=/tmp

##########################################################
# Download the latest version of CounterStrikeSharp plugin
##########################################################

echo "Downloading CounterStrikeSharp..."
CSS_URL="https://api.github.com/repos/roflmuffin/CounterStrikeSharp/releases/latest"
HTML=$(curl -s $CSS_URL)

# Check if curl was successful
if [ $? -ne 0 ] || [ -z "$HTML" ]; then
    echo "ERROR: Failed to fetch CounterStrikeSharp release information"
    exit 1
fi

# If I have the latest version, I can stop the script
ID=$(echo $HTML | jq -r '.id')
echo "The CS Sharp plugin id: $ID"

# Check if we already have this version (unless forcing update)
VERSION_FILE="${ADDONS_DIR}/.css_version"
if [ -f "$VERSION_FILE" ] && [ "$FORCE_UPDATE" != "true" ]; then
    CURRENT_ID=$(cat "$VERSION_FILE")
    if [ "$CURRENT_ID" = "$ID" ]; then
        echo "CounterStrikeSharp is already up to date (ID: $ID)"
        exit 0
    fi
fi

# New version available, download the file
CSS_SHARP_FILE="$BASE_FOLDER/cssharp.zip"
ASSETS=$(echo $HTML | jq -r '.assets[] | select(.name | test("with-runtime.*linux")) | .browser_download_url')

if [ -z "$ASSETS" ]; then
    echo "ERROR: No suitable CounterStrikeSharp asset found for Linux"
    exit 1
fi

for URL in $ASSETS; do
    echo "Downloading CounterStrikeSharp from: $URL"
    curl -L -o "$CSS_SHARP_FILE" "$URL"
    if [ $? -eq 0 ]; then
        break
    fi
done

if [ ! -f "$CSS_SHARP_FILE" ]; then
    echo "ERROR: Failed to download CounterStrikeSharp"
    exit 1
fi

#########################################################
# Download the latest version of Metamod plugin framework
#########################################################
echo "Downloading MetaMod..."
URL="https://www.sourcemm.net/downloads.php?branch=dev"

# Fetch HTML content
HTML=$(curl -s $URL)

if [ $? -ne 0 ] || [ -z "$HTML" ]; then
    echo "ERROR: Failed to fetch MetaMod download page"
    exit 1
fi

# Extract download link
FILE_URL=$(echo $HTML | grep -oP "(?<=href=')[^']*linux.tar.gz" | head -1)

if [ -z "$FILE_URL" ]; then
    echo "ERROR: Could not find MetaMod download link"
    exit 1
fi

FILE_URL=$(echo $FILE_URL | awk '{print $1}')
META_MODE_FILE="$BASE_FOLDER/metamod.tar.gz"

# Download the file
echo "Downloading MetaMod from: $FILE_URL"
curl -L -o "$META_MODE_FILE" "$FILE_URL"

if [ ! -f "$META_MODE_FILE" ]; then
    echo "ERROR: Failed to download MetaMod"
    exit 1
fi

########################################################
# Extract metamod and CounterStrikeSharp plugin files
# and merge them into the destination directory
########################################################
echo "Extracting and installing plugins..."

CSS_SHARP_UNZIP_DIR="$BASE_FOLDER/cssharp"
rm -rf "$CSS_SHARP_UNZIP_DIR"  # Clean up any previous extraction

# Extract the files
tar -xf "$META_MODE_FILE" -C "$BASE_FOLDER"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to extract MetaMod"
    exit 1
fi

unzip -o "$CSS_SHARP_FILE" -d "$CSS_SHARP_UNZIP_DIR"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to extract CounterStrikeSharp"
    exit 1
fi

# Merge directories if they exist
SOURCE_DIR="$CSS_SHARP_UNZIP_DIR/addons"
DESTINATION_DIR="$BASE_FOLDER/addons"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "ERROR: CounterStrikeSharp addons directory not found after extraction"
    exit 1
fi

mkdir -p "$DESTINATION_DIR"
cp -r "$SOURCE_DIR/"* "$DESTINATION_DIR/"

#################################################
# Clone the repo that contains the CSSharp plugin
#################################################
echo "Building custom IxigoPlugin..."
CSGO_UTIL_DIR="$BASE_FOLDER/csgo_util"
rm -rf "$CSGO_UTIL_DIR"  # Clean up any previous clone

git clone "https://github.com/marcosolina/csgo_util.git" "$CSGO_UTIL_DIR"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to clone csgo_util repository"
    exit 1
fi

IXIGO_PLUGIN_DIR="$CSGO_UTIL_DIR/CsgoPlugins/IxigoPlugin"
IXIGO_PLUGIN_BIN_DIR="$CSGO_UTIL_DIR/CsgoPlugins/IxigoPlugin/bin/Debug/net8.0"

if [ ! -d "$IXIGO_PLUGIN_DIR" ]; then
    echo "ERROR: IxigoPlugin directory not found in repository"
    exit 1
fi

# Check if dotnet is available
if ! command -v dotnet &> /dev/null; then
    echo "ERROR: .NET SDK not found. Please install .NET 8.0 SDK"
    exit 1
fi

# Build the plugin
cd "$IXIGO_PLUGIN_DIR"
dotnet add package CounterStrikeSharp.API
dotnet clean
dotnet build

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build IxigoPlugin"
    exit 1
fi

if [ ! -d "$IXIGO_PLUGIN_BIN_DIR" ]; then
    echo "ERROR: IxigoPlugin build output not found"
    exit 1
fi

# Copy the plugin to the destination directory
CSS_SHARP_DIRECTORY_PLUGINS="$DESTINATION_DIR/counterstrikesharp/plugins"
IXIGO_PLUGIN_DEST_DIR="$CSS_SHARP_DIRECTORY_PLUGINS/IxigoPlugin"
mkdir -p "$IXIGO_PLUGIN_DEST_DIR"
cp -r "$IXIGO_PLUGIN_BIN_DIR/"* "$IXIGO_PLUGIN_DEST_DIR/"

echo "Setting permissions..."
sudo chown $LOGGED_USER:$LOGGED_USER -R $DESTINATION_DIR
sudo chmod 755 -R $DESTINATION_DIR

# Backup existing addons if they exist
if [ -d "$ADDONS_DIR" ]; then
    echo "Backing up existing addons..."
    sudo mv "$ADDONS_DIR" "${ADDONS_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
fi

echo "Installing addons to CS2 directory..."
sudo cp -r $DESTINATION_DIR "${CS2_DIR}/game/csgo"

sudo chown $LOGGED_USER:$LOGGED_USER -R $ADDONS_DIR
sudo chmod 755 -R $ADDONS_DIR

# Save version information
echo "$ID" > "$VERSION_FILE"

echo "MetaMod and CounterStrikeSharp installation completed successfully!"
echo "Installed CounterStrikeSharp version ID: $ID"

# Clean up temporary files
rm -f "$CSS_SHARP_FILE" "$META_MODE_FILE"
rm -rf "$CSS_SHARP_UNZIP_DIR" "$CSGO_UTIL_DIR"

echo "Installation complete. You can now start your CS2 server."