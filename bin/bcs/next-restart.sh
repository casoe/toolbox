#!/bin/bash
# Name : next-restart.sh
# Autor: Carsten Söhrens

# Überprüfe, auf welcher Maschine das Skript ausgeführt wird
# Stelle ggf. eine Nachfrage, sofern es sich um das Live-System handelt
machine=`uname -n`
bcshome=/opt/projektron/bcs/server_next

if [[ "$machine" == 'bcs' ]]; then
        read -p "This is the live server. Sure to continue? Type in YES!" choice
        case "$choice" in
          YES! ) echo "Continue...";;
          * ) echo "Abort" && exit 1;;
        esac
fi

START=$(date +%s)

# Stoppe BCS, löschen der BCS-Logdateien nur, wenn es sich nicht um das Livesystem handelt
echo Shutdown BCS...
$bcshome/bin/ProjektronBCS.sh stop

if [[ "$machine" != 'gs3-bcs' ]]; then
        echo Emptying BCS log directory...
        rm -rf $bcshome/log/*
        rm -rf $bcshome/tomcat/logs/*
fi

# Neustart von BCS
echo Start BCS...
$bcshome/bin/ProjektronBCS.sh start

END=$(date +%s)

echo ...Fertig
echo Restart time: `date -u -d "0 $END seconds - $START seconds" +"%H:%M:%S"`

