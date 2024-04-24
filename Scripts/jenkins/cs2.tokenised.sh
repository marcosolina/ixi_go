#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

apt update

LOGGED_USER=$(logname)


STEAMAPPID=730
HOMEDIR="/home/${LOGGED_USER}"
CS2_DIR="${HOMEDIR}/cs2"
JAR_FOLDER="${CS2_DIR}/jars"
STEAMCMDDIR="${HOMEDIR}/steamcmd"
STEAM_USER="#{STEAM_USER}#"
STEAM_PASSW="#{STEAM_PASSW}#"

RCON_PASSWORD="#{RCON_PASSWORD}#"
SERVER_PASSWORD="#{SERVER_PASSWORD}#"
STEAM_CSGO_KEY="#{STEAM_CSGO_KEY}#"
STEAM_API_KEY="#{STEAM_API_KEY}#"
IXIGO_PROFILE="rasp,azure"
IXIGO_EUREKA_SERVER="https://marco.selfip.net/discovery/eureka"
IXIGO_CONFIG_SRV_URI="https://marco.selfip.net/config"
IXIGO_CFG_SRV_USER="#{IXIGO_CFG_SRV_USER}#"
IXIGO_CFG_SRV_PW="#{IXIGO_CFG_SRV_PW}#"

apt install -y curl git default-jre maven tmux screen lib32gcc-s1 jq lib32stdc++6 unzip

# Ixigo services setup
cd /tmp
git clone --branch main https://github.com/marcosolina/csgo_util.git

WORKSPACE_FOLDER=/tmp/csgo_util

mvn clean install -f $WORKSPACE_FOLDER/IxigoServerHelperContract/pom.xml
mvn clean install -f $WORKSPACE_FOLDER/IxigoDemManagerContract/pom.xml
mvn clean install -f $WORKSPACE_FOLDER/IxigoDiscordBotContract/pom.xml
mvn clean install -f $WORKSPACE_FOLDER/IxigoEventDispatcherContract/pom.xml
mvn clean install -f $WORKSPACE_FOLDER/IxigoPlayersManagerContract/pom.xml
mvn clean install -f $WORKSPACE_FOLDER/IxigoRconApiContract/pom.xml
mvn clean install -f $WORKSPACE_FOLDER/IxigoLibrary/pom.xml
mvn clean install -f $WORKSPACE_FOLDER/IxigoParent/pom.xml
mvn clean package -f $WORKSPACE_FOLDER/IxigoServerHelper/pom.xml

git clone --branch main https://github.com/marcosolina/ixi_go.git

su "${LOGGED_USER}" -c \
		"mkdir -p \"${JAR_FOLDER}\" \
				&& cp /tmp/ixi_go/Scripts/jars/startHelper.sh \"${JAR_FOLDER}\" \
            && cp $WORKSPACE_FOLDER/IxigoServerHelper/target/IxigoServerHelper*.jar $JAR_FOLDER/IxigoServerHelper.jar \
            && sed -i -e 's/\r$//' $JAR_FOLDER/*.sh \
            && chmod +x $JAR_FOLDER/*" \


# Steam Setup
echo ""                                                     | tee -a /etc/profile
echo "export ENV_STEAM_USER=$STEAM_USER"                    | tee -a /etc/profile
echo "export ENV_STEAM_PASSW=$STEAM_PASSW"                  | tee -a /etc/profile
echo ""                                                     | tee -a /etc/profile
echo "export ENV_STEAM_CSGO_KEY=$STEAM_CSGO_KEY"            | tee -a /etc/profile
echo "export ENV_STEAM_API_KEY=$STEAM_API_KEY"              | tee -a /etc/profile
echo "export ENV_CSGO_INSTALL_FOLDER=$CS2_DIR"              | tee -a /etc/profile
echo "export IXIGO_PROFILE=$IXIGO_PROFILE"                  | tee -a /etc/profile
echo "export IXIGO_EUREKA_SERVER=$IXIGO_EUREKA_SERVER"      | tee -a /etc/profile
echo "export IXIGO_CONFIG_SERVER_URI=$IXIGO_CONFIG_SRV_URI" | tee -a /etc/profile
echo "export IXIGO_CONFIG_SERVER_USER=$IXIGO_CFG_SRV_USER"  | tee -a /etc/profile
echo "export IXIGO_CONFIG_SERVER_PASSW=$IXIGO_CFG_SRV_PW"   | tee -a /etc/profile
echo "export IXIGO_CSGO_PASSW=$SERVER_PASSWORD"             | tee -a /etc/profile

echo "Retrieving external IP..."
curl ipinfo.io/ip

IP=$(curl ipinfo.io/ip)
echo "eureka.instance.ipAddress=$IP" > $JAR_FOLDER/application.properties
echo "export CSGO_IP=$IP"	| tee -a /etc/profile

su "${LOGGED_USER}" -c \
		"mkdir -p \"${STEAMCMDDIR}\" \
				&& mkdir -p \"${CS2_DIR}\" \
                && curl -fsSL 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar xvzf - -C \"${STEAMCMDDIR}\" \
                && \"${STEAMCMDDIR}/steamcmd.sh\" +quit \
                && ln -s \"${STEAMCMDDIR}/linux32/steamclient.so\" \"${STEAMCMDDIR}/steamservice.so\" \
                && mkdir -p \"${HOMEDIR}/.steam/sdk32\" \
                && ln -s \"${STEAMCMDDIR}/linux32/steamclient.so\" \"${HOMEDIR}/.steam/sdk32/steamclient.so\" \
                && ln -s \"${STEAMCMDDIR}/linux32/steamcmd\" \"${STEAMCMDDIR}/linux32/steam\" \
                && mkdir -p \"${HOMEDIR}/.steam/sdk64\" \
                && ln -s \"${STEAMCMDDIR}/linux64/steamclient.so\" \"${HOMEDIR}/.steam/sdk64/steamclient.so\" \
                && ln -s \"${STEAMCMDDIR}/linux64/steamcmd\" \"${STEAMCMDDIR}/linux64/steam\" \
                && ln -s \"${STEAMCMDDIR}/steamcmd.sh\" \"${STEAMCMDDIR}/steam.sh\"" \
 	&& ln -s "${STEAMCMDDIR}/linux64/steamclient.so" "/usr/lib/x86_64-linux-gnu/steamclient.so" \

echo '#!/bin/bash' > /etc/rc.local
echo "sudo -iu ${LOGGED_USER} /usr/bin/screen -A -m -d -L -S cs2 bash -c \"${HOMEDIR}/startCs2ServerAzure.sh; exec bash\"" >> /etc/rc.local
echo 'exit 0' >> /etc/rc.local
chmod +x /etc/rc.local
