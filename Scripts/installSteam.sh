#!/bin/bash

# Install Steam CMD
read -p "Do you want to install steamcmd? (y/n): " installSteamCmd
if [ $installSteamCmd = 'y' ]
then
  sudo add-apt-repository multiverse
  sudo dpkg --add-architecture i386
  sudo apt update
  sudo apt install -y lib32gcc1 steamcmd
fi


# I Used some ENV properties to automate the transfer
# of the DEM files on the Rasp that is going to process
# them and extract the scores that we use for our
# statistics
CSGO_SCRIPTS_FOLDER=$(dirname $(dirname $(readlink -f "$0")))/Scripts
echo ""
echo "To start the server run: $CSGO_SCRIPTS_FOLDER/startIxigoServer.sh"
echo ""
read -p "Do you want to set the Env Variables? (y/n): " setEnvProps

if [ $setEnvProps = 'y' ]
then
  read -p "Type here your STEAM CSGO KEY: "                               STEAM_CSGO_KEY
  read -p "Type here your STEAM API KEY: "                                STEAM_API_KEY
  read -p "Type here your IxiGo Profile to user: "                        IXIGO_PROFILE
  read -p "Type here the url of the IxiGo Eureka server (example: http://localhost:8765/ixigodiscovery/eureka): "   IXIGO_EUREKA_SERVER_URI
  read -p "Type here the url of the IxiGo Config server (example: http://localhost:8888/config): "                  IXIGO_CONFIG_SRV_URI
  read -p "Type here the username of the IxiGo Config server: "           IXIGO_CFG_SRV_USER
  read -p "Type here the password of the IxiGo Config server: "           IXIGO_CFG_SRV_PW
  read -p "Type here the Postgres username: "                             IXIGO_POSTGRES_USER
  read -p "Type here the Postgres password: "                             IXIGO_POSTGRES_PASSW

  CSGO_INSTALL_FOLDER=$(dirname $(dirname $(readlink -f "$0")))/CsgoServer

  echo ""                                                     | sudo tee -a /etc/profile
  echo "export ENV_STEAM_CSGO_KEY=$STEAM_CSGO_KEY"            | sudo tee -a /etc/profile
  echo "export ENV_STEAM_API_KEY=$STEAM_API_KEY"              | sudo tee -a /etc/profile
  echo "export ENV_CSGO_INSTALL_FOLDER=$CSGO_INSTALL_FOLDER"  | sudo tee -a /etc/profile
  echo "export IXIGO_PROFILE=$IXIGO_PROFILE"                  | sudo tee -a /etc/profile
  echo "export IXIGO_EUREKA_SERVER=$IXIGO_EUREKA_SERVER_URI"  | sudo tee -a /etc/profile
  echo "export IXIGO_CONFIG_SERVER_URI=$IXIGO_CONFIG_SRV_URI" | sudo tee -a /etc/profile
  echo "export IXIGO_CONFIG_SERVER_USER=$IXIGO_CFG_SRV_USER"  | sudo tee -a /etc/profile
  echo "export IXIGO_CONFIG_SERVER_PASSW=$IXIGO_CFG_SRV_PW"   | sudo tee -a /etc/profile
  echo "export IXIGO_POSTGRES_USER=$IXIGO_POSTGRES_USER"      | sudo tee -a /etc/profile
  echo "export IXIGO_POSTGRES_PASSW=$IXIGO_POSTGRES_PASSW"    | sudo tee -a /etc/profile

  echo ""
  echo ""
  echo "Please restart your machine"
  echo ""
  echo ""
fi


