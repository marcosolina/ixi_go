#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
APP_FOLDER=$SCRIPT_DIR/
APP_JAR_1=IxigoServerHelper.jar
APP_NOHUP_1=${APP_FOLDER}IxigoServerHelper.log
APP_PID_FILE_1=${APP_FOLDER}IxigoServerHelper.pid

APP_JAR_2=IxigoDiscordBot.jar
APP_NOHUP_2=${APP_FOLDER}IxigoDiscordBot.log
APP_PID_FILE_2=${APP_FOLDER}IxigoDiscordBot.pid

case "$1" in
start)
   cd $APP_FOLDER
   nohup java -jar $APP_JAR_1 >> $APP_NOHUP_1 2>&1&
   echo $!>$APP_PID_FILE_1
   chmod 775 $APP_PID_FILE_1
   nohup java -jar $APP_JAR_2 >> $APP_NOHUP_2 2>&1&
   echo $!>$APP_PID_FILE_2
   chmod 775 $APP_PID_FILE_2
   ;;
stop)
   kill `cat $APP_PID_FILE_1`
   rm $APP_PID_FILE_1
   kill `cat $APP_PID_FILE_2`
   rm $APP_PID_FILE_2
   ;;
restart)
   $0 stop
   $0 start
   ;;
status)
   if [ -e $APP_PID_FILE_1 ]; then
      echo RoundParser is running, pid=cat $APP_PID_FILE_1
   else
      echo RoundParser is NOT running
   fi
   if [ -e $APP_PID_FILE_2 ]; then
      echo RoundParser is running, pid=cat $APP_PID_FILE_2
   else
      echo RoundParser is NOT running
      exit 1
   fi
   ;;
*)
   echo "Usage: $0 {start|stop|status|restart}"
esac

exit 0
