#!/bin/bash
# Name : download.sh
# Autor: Carsten Söhrens
# Version für das Live-System gs3-bcs und Test-System gs3-bcstest

if [ -z $1 ]
then
  echo "Parameter fehlt"
    if [[ $1 == *"https"* ]]; then
      echo "Version angeben (nicht die URL)"
      exit
    fi
  exit
fi

FILE=/root/.projektron
if [ ! -f $FILE ]; then
  echo "File mit Zugangsdaten fehlt"
  exit
fi

MAINVERSION=`expr substr $1 1 4`
SUBVERSION=$1
TARGET=https://support.projektron.de/webdav/BCS/Projekte/Downloads/Projektron_BCS_$MAINVERSION/$SUBVERSION/.Dateien/projektron-bcs-$SUBVERSION.zip

# Credentials aus Datei einlesen
source /root/.projektron

# Einloggen und Download durchführen
wget -O /dev/null --post-data $CREDENTIALS --keep-session-cookies --save-cookies cookies.txt https://support.projektron.de/bcs/login
wget --load-cookies cookies.txt $TARGET
rm cookies.txt
