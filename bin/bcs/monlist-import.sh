#!/bin/bash
# Name : monlist-import.sh
# Autor: Carsten Söhrens

FULLDATE=`date +\%Y-\%m-\%d`
WORKDIR=/opt/projektron/bcs/monlist
FULLDATE=`date +\%Y-\%m-\%d`
FILE=$1

# Wechsel in das Arbeitsverzeichnis
cd $WORKDIR

# Check ob ein Inputfile vorhanden ist
if [ -z $1 ]
then
  echo Import-File fehlt
  exit
fi

# Import der Daten
monapi import $FILE 2>&1 |tee -a $WORKDIR/log/import_$FULLDATE.log
