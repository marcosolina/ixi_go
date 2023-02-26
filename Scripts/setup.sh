#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

apt update

INSTALL_PATH="/home/ixigo"

# Creating Ixigo Group and User
IXIGO_GROUP=ixigo
IXIGO_USER_NAME=ixigo
IXIGO_USR_PASS=0123456789

ENV_METAMOD_VERSION=1.12
ENV_SOURCEMOD_VERSION=1.12

SCRIPTS_FOLDER=$INSTALL_PATH/ixi_go/Scripts
JAR_FOLDER=$INSTALL_PATH/ixi_go/Scripts/jars
CSGO_DIR=$INSTALL_PATH/ixi_go/CsgoServer/csgo
CFG_FOLDER=$INSTALL_PATH/ixi_go/CsgoServer/csgo/cfg

read -p "Is this a clean install? (y/n): " cleanInstall

if [ $cleanInstall = 'y' ]
then
	addgroup $IXIGO_GROUP
	useradd -s /bin/bash -m -g $IXIGO_GROUP $IXIGO_USER_NAME
	passwd -d $IXIGO_USER_NAME
	
	# Setting default user password and
	# forcing passowrd reset at first login
	echo "$IXIGO_USER_NAME:$IXIGO_USR_PASS" | chpasswd
	passwd --expire $IXIGO_USER_NAME
  
	echo "$IXIGO_USER_NAME ALL = NOPASSWD: /sbin/shutdown"    | sudo tee -a /etc/sudoers
	echo "$IXIGO_USER_NAME ALL = NOPASSWD: /sbin/reboot"      | sudo tee -a /etc/sudoers
	
	read -p "Do you want to install the DynDns client? (y/n): " INSTALL_DYNDNS
	if [ $INSTALL_DYNDNS = 'y' ]
	then
	  apt install -y ddclient
	fi
	
	apt install -y curl git default-jre maven screen
else
	cp $CFG_FOLDER/server.cfg /tmp/
	rm -rf $INSTALL_PATH/ixi_go
fi

# Prepare the Jars
cd /tmp
git clone https://github.com/marcosolina/csgo_util.git
git clone https://github.com/marcosolina/javautils.git

mvn clean install -f /tmp/javautils/Utils/pom.xml
mvn clean package -f ./csgo_util/IxigoServerHelper/pom.xml
mvn clean package -f ./csgo_util/IxigoDiscordBot/pom.xml -P h2


cd $INSTALL_PATH
git clone --branch refactoring https://github.com/marcosolina/ixi_go.git

# Are we in a metamod container and is the metamod folder missing?
if  [ ! -z "$ENV_METAMOD_VERSION" ] && [ ! -d "${CSGO_DIR}/addons/metamod" ]; then
	LATESTMM=$(wget -qO- https://mms.alliedmods.net/mmsdrop/"${ENV_METAMOD_VERSION}"/mmsource-latest-linux)
	wget -qO- https://mms.alliedmods.net/mmsdrop/"${ENV_METAMOD_VERSION}"/"${LATESTMM}" | tar xvzf - -C "${CSGO_DIR}"	
fi

# Are we in a sourcemod container and is the sourcemod folder missing?
if  [ ! -z "$ENV_SOURCEMOD_VERSION" ] && [ ! -d "${CSGO_DIR}/addons/sourcemod" ]; then
	LATESTSM=$(wget -qO- https://sm.alliedmods.net/smdrop/"${ENV_SOURCEMOD_VERSION}"/sourcemod-latest-linux)
	wget -qO- https://sm.alliedmods.net/smdrop/"${ENV_SOURCEMOD_VERSION}"/"${LATESTSM}" | tar xvzf - -C "${CSGO_DIR}"
	cp -r $SCRIPTS_FOLDER/csgo/addons/sourcemod/plugins/* ${CSGO_DIR}/addons/sourcemod/plugins
fi

sed -i -e 's/\r$//' $JAR_FOLDER/*
chmod +x $JAR_FOLDER/*

# Remove any "Windows" character and make
# the scripts executable
sed -i -e 's/\r$//' $SCRIPTS_FOLDER/*
chmod +x $SCRIPTS_FOLDER/*

mv /tmp/csgo_util/IxigoDiscordBot/target/IxigoDiscordBot*.jar $JAR_FOLDER/IxigoDiscordBot.jar
mv /tmp/csgo_util/IxigoServerHelper/target/IxigoServerHelper*.jar $JAR_FOLDER/IxigoServerHelper.jar

rm -rf /root/.m2/*


if [ $cleanInstall = 'y' ]
then
	# Set the IxiGo Game server passowrd
	echo ""
	echo ""
	read -p "Choose your RCON password: " RCON_PASSWORD
	read -p "Choose your SERVER  password: " SERVER_PASSWORD
	
	sed -i -e "s/RCON_PASSWORD/$RCON_PASSWORD/g" $CFG_FOLDER/server.cfg
	sed -i -e "s/SERVER_PASSWORD/$SERVER_PASSWORD/g" $CFG_FOLDER/server.cfg
	
	echo "Installing Steam CMD"
	$SCRIPTS_FOLDER/installSteam.sh
else
	mv /tmp/server.cfg $CFG_FOLDER
fi


echo "Login with username: $IXIGO_USER_NAME and password: $IXIGO_USR_PASS"
echo ""

chown $IXIGO_GROUP:$IXIGO_USER_NAME -R $INSTALL_PATH/ixi_go
