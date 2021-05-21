#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
APP_FOLDER=$SCRIPT_DIR/
APP_JAR=IxigoServerHelper.jar
APP_NOHUP=${APP_FOLDER}IxigoServerHelper.log
APP_PID_FILE=${APP_FOLDER}IxigoServerHelper.pid

case "$1" in
start)
   cd $APP_FOLDER
   nohup java -jar $APP_JAR >> $APP_NOHUP 2>&1&
   echo $!>$APP_PID_FILE
   chmod 775 $APP_PID_FILE
   ;;
stop)
   kill `cat $APP_PID_FILE`
   rm $APP_PID_FILE
   ;;
restart)
   $0 stop
   $0 start
   ;;
status)
   if [ -e $APP_PID_FILE ]; then
      echo RoundParser is running, pid=cat $APP_PID_FILE
   else
      echo RoundParser is NOT running
      exit 1
   fi
   ;;
*)
   echo "Usage: $0 {start|stop|status|restart}"
esac

exit 0
