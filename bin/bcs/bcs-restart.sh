#!/bin/bash
# Name : bcs-restart.sh
# Autor: Carsten Söhrens

### Überprüfe, auf welcher Maschine das Skript ausgeführt wird
### Stelle ggf. eine Nachfrage, sofern es sich um das Live-System handelt
MACHINE=`uname -n`

if [[ "$MACHINE" == 'bcs' ]]; then
	read -p "This is the live server. Sure to continue? Type in YES!" choice
	case "$choice" in
		YES!)
			echo "Continue with 5 minutes countdown"
			/opt/projektron/bcs/server/bin/AdminMessage.sh "System shutting down for restart in 5 minutes, please save your work in time."
			echo 5 minutes remaining, waiting 60 sec
			sleep 60
			/opt/projektron/bcs/server/bin/AdminMessage.sh "System shutting down for restart in 4 minutes, please save your work in time."
			echo 4 minutes remaining, waiting 60 sec
			sleep 60
			/opt/projektron/bcs/server/bin/AdminMessage.sh "System shutting down for restart in 3 minutes, please save your work in time."
			echo 3 minutes remaining, waiting 60 sec
			sleep 60
			/opt/projektron/bcs/server/bin/AdminMessage.sh "System shutting down for restart in 2 minutes, please save your work in time."
			echo 2 minutes remaining, waiting 60 sec
			sleep 60
			/opt/projektron/bcs/server/bin/AdminMessage.sh "System shutting down for restart in 1 minute, please save your work in time."
			echo 1 minute remaining, waiting 60 sec
			sleep 60
			;;
		*)
			echo "Abort" && exit 1
			;;
	esac
fi

START=$(date +%s)

### Stoppe BCS, löschen der BCS-Logdateien nur, wenn es sich um das Testsystem handelt
echo Shutdown BCS...
/opt/projektron/bcs/server/bin/ProjektronBCS.sh stop

if [[ "$MACHINE" != 'bcs' ]]; then
        echo Emptying BCS log directory...
        rm -rf /opt/projektron/bcs/server/log/*
        rm -rf /opt/projektron/bcs/server/tomcat/logs/*
fi

### Neustart von BCS
echo Start BCS...
/opt/projektron/bcs/server/bin/ProjektronBCS.sh start

END=$(date +%s)

echo ...Fertig
echo Restart time: `date -u -d "0 $END seconds - $START seconds" +"%H:%M:%S"`

