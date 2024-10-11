#!/bin/bash

BASE_FOLDER=$(dirname "$0")
GIT_FOLDER="$BASE_FOLDER/../../"

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
ASSETS=$(echo $HTML | jq -r '.assets[] | select(.name | test("with-runtime-build.*linux")) | .browser_download_url')
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

# Clean up
rm -f "$META_MODE_FILE"
rm -f "$CSS_SHARP_FILE"
rm -rf "$CSS_SHARP_UNZIP_DIR"
rm -rf "$CSGO_UTIL_DIR"

exit 0
