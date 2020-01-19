#!/bin/bash
# Name : ods30-copyfromlive.sh
# Autor: Carsten Söhrens

### Überprüfe, auf welcher Maschine das Skript ausgeführt wird
### Stelle ggf. eine Nachfrage, sofern es sich um das Live-System handelt
MACHINE=`uname -n`

if [[ "$MACHINE" == 'bcs' ]]; then
        read -p "This is the live server. Sure to continue? Type in YES!" choice
        case "$choice" in
          YES! ) echo "Continue...";;
          * ) echo "Abort" && exit 1;;
        esac
fi

BCSHOME=/opt/projektron/bcs/server
PGDUMP=/usr/bin/pg_dump
PGRESTORE=/usr/bin/pg_restore
FULLDATE=`date +\%Y-\%m-\%d`
BACKUP=/opt/projektron/bcs/backup/ods30_backup_${FULLDATE}.zip

echo Dump von Live-ODS
$PGDUMP -v -Fc -h 172.16.1.103 -U bcs --no-password -f $BACKUP ods30

echo Drop and create database
su -c "dropdb --if-exists ods30" postgres
su -c "createdb ods30" postgres

echo Restore auf Test-ODS
$PGRESTORE -v -c -w -n public -h localhost -p 5432 -d ods30 -U bcs $BACKUP


