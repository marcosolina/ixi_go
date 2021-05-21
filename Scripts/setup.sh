#!/bin/bash

# Clone the repo in the folder specified by the user
echo ""
echo ""
read -p "Where do you want to install the server? (/full/path/): " INSTALL_PATH
cd $INSTALL_PATH

git clone https://github.com/marcosolina/ixi_go.git


SCRIPTS_FOLDER=$INSTALL_PATH/ixi_go/Scripts
CFG_FOLDER=$INSTALL_PATH/ixi_go/CsgoServer/csgo/cfg

# Remove any "Windows" character and make
# the scripts executable
sed -i -e 's/\r$//' $SCRIPTS_FOLDER/*
chmod +x $SCRIPTS_FOLDER/*

# Set the IxiGo Game server passowrd
read -p "Choose your RCON password: " RCON_PASSWORD
read -p "Choose your SERVER  password: " SERVER_PASSWORD

sed -i -e "s/RCON_PASSWORD/$RCON_PASSWORD/g" $CFG_FOLDER/server.cfg
sed -i -e "s/SERVER_PASSWORD/$SERVER_PASSWORD/g" $CFG_FOLDER/server.cfg

echo "Installing Steam CMD"
$SCRIPTS_FOLDER/installSteam.sh
