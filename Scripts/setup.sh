#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

apt update

# Clone the repo in the folder specified by the user
echo ""
echo ""
read -p "Where do you want to install the server? (/full/path/): " INSTALL_PATH

IXIGO_GROUP=ixigo

addgroup $IXIGO_GROUP

read -p "Ixigo User Name: " IXIGO_USER_NAME
useradd -s /bin/bash -m -g $IXIGO_GROUP $IXIGO_USER_NAME

echo "Set a password for the user: $IXIGO_USER_NAME"
passwd $IXIGO_USER_NAME

echo "$IXIGO_USER_NAME ALL = NOPASSWD: /sbin/shutdown"    | sudo tee -a /etc/sudoers

read -p "Do you want to install the DynDns client? (y/n): " INSTALL_DYNDNS
if [ $INSTALL_DYNDNS = 'y' ]
then
  apt install -y ddclient
fi


apt install -y curl git default-jre maven screen

cd /tmp
git clone https://github.com/marcosolina/csgo_util.git
git clone https://github.com/marcosolina/javautils.git

mvn clean install -f /tmp/javautils/Utils/pom.xml
mvn clean package -f ./csgo_util/IxigoServerHelper/pom.xml
mvn clean package -f ./csgo_util/IxigoDiscordBot/pom.xml


cd $INSTALL_PATH
git clone https://github.com/marcosolina/ixi_go.git


SCRIPTS_FOLDER=$INSTALL_PATH/ixi_go/Scripts
JAR_FOLDER=$INSTALL_PATH/ixi_go/Scripts/jars
CFG_FOLDER=$INSTALL_PATH/ixi_go/CsgoServer/csgo/cfg

sed -i -e 's/\r$//' $JAR_FOLDER/*
chmod +x $JAR_FOLDER/*

# Remove any "Windows" character and make
# the scripts executable
sed -i -e 's/\r$//' $SCRIPTS_FOLDER/*
chmod +x $SCRIPTS_FOLDER/*

mv /tmp/csgo_util/IxigoDiscordBot/target/IxigoDiscordBot*.jar $JAR_FOLDER/IxigoDiscordBot.jar
mv /tmp/csgo_util/IxigoServerHelper/target/IxigoServerHelper*.jar $JAR_FOLDER/IxigoServerHelper.jar

rm -rf /root/.m2/*

# Set the IxiGo Game server passowrd
echo ""
echo ""
read -p "Choose your RCON password: " RCON_PASSWORD
read -p "Choose your SERVER  password: " SERVER_PASSWORD

sed -i -e "s/RCON_PASSWORD/$RCON_PASSWORD/g" $CFG_FOLDER/server.cfg
sed -i -e "s/SERVER_PASSWORD/$SERVER_PASSWORD/g" $CFG_FOLDER/server.cfg

echo "Installing Steam CMD"
$SCRIPTS_FOLDER/installSteam.sh

chown $IXIGO_GROUP:$IXIGO_USER_NAME -R $INSTALL_PATH/ixi_go
