#!/bin/bash

# Clone the repo in the folder specified by the user
echo ""
echo ""
read -p "Where do you want to install the server? (/full/path/): " INSTALL_PATH

sudo apt update
sudo apt install -y git default-jre maven

cd /tmp
git clone https://github.com/marcosolina/csgo_util.git
git clone https://github.com/marcosolina/javautils.git
git clone https://github.com/marcosolina/WebJar.git

mvn clean install -f /tmp/javautils/Utils/pom.xml
mvn clean install -f /tmp/javautils/Partitioning/pom.xml
mvn clean install -f /tmp/WebJar/pom.xml
mvn clean package -f ./csgo_util/IxigoServerHelper/pom.xml
mvn clean package -f ./csgo_util/IxigoDiscordBot/pom.xml


cd $INSTALL_PATH
git clone -b cloud https://github.com/marcosolina/ixi_go.git


SCRIPTS_FOLDER=$INSTALL_PATH/ixi_go/Scripts
JAR_FOLDER=$INSTALL_PATH/ixi_go/Scripts/jars
CFG_FOLDER=$INSTALL_PATH/ixi_go/CsgoServer/csgo/cfg

mv /tmp/csgo_util/IxigoDiscordBot/target/IxigoDiscordBot*.jar $JAR_FOLDER/IxigoDiscordBot.jar
mv /tmp/csgo_util/IxigoServerHelper/target/IxigoServerHelper*.jar $JAR_FOLDER/IxigoServerHelper.jar

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
