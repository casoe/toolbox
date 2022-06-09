#!/bin/bash
# Name : next-copyfromlive.sh
# Autor: Carsten Söhrens

# set -x

### Überprüfe, auf welcher Maschine das Skript ausgeführt wird
### Abbruch, sofern es sich um das Live-System handelt
MACHINE=`uname -n`

if [[ "$MACHINE" == 'bcs' ]]; then
	echo "This is the live server. Abort!" && exit 1
else
	DATABASE=localhost
fi

BCSHOME=/opt/projektron/bcs/server_next
LOG=$BCSHOME/copyfromlive.log
PGDUMP=/usr/bin/pg_dump
PGRESTORE=/usr/bin/pg_restore
FULLDATE=`date +\%Y-\%m-\%d`
PSQL="psql postgresql://bcs@$DATABASE/bcs_next"

# Redirect stdout ( > ) and stderr (2>&1) into a named pipe ( >() ) running "tee"
exec > >(tee -ia $LOG)
exec 2>&1

START=$(date +%s)

echo Shutdown BCS-Next
$BCSHOME/bin/ProjektronBCS.sh stop

if [[ "$MACHINE" != 'bcs' ]]; then
	echo "Testserver-Restore: Emptying BCS log directory"
	rm -rf $BCSHOME/log/*
fi

### Es werden alle Tabellen gedropped; sofern schon eine neue Version auf Next installiert war,
### lässt sich diese ansonsten nicht starten, weil der Datenbankmanager beim Anlegen neuer
### Tabellen crashed (diese sind schon vorhanden und werden bei pg_restore nicht gedropped)
$PSQL -t -c "select 'drop table \"' || tablename || '\" cascade;' from pg_tables where schemaname='public'" | $PSQL

echo Verlinkung und Spiegelung des Data-Verzeichnisses
rm -rf $BCSHOME/data/files/*
cp -val  $BCSHOME/../restore/files/* $BCSHOME/data/files/
rsync -avP --delete  $BCSHOME/../restore/ftindex/ $BCSHOME/data/FTIndex

echo Restore der DB
$PGRESTORE -v -j 12 -w -n public -h localhost -p 5432 -d bcs_next -U bcs -Fd $BCSHOME/../restore/db/

if [[ "$MACHINE" != 'bcs' ]]; then
	echo "Testserver-Restore: Deactivate Exchange-Synchronisation for all users"
	$PSQL -c "UPDATE custattr_int SET value=0 WHERE attrib='syncAdapterActive';"
fi

# Server-ID entfernen
$BCSHOME/bin/Restore.sh -rmserverid

echo Start BCS
$BCSHOME/bin/ProjektronBCS.sh start

mv $LOG $BCSHOME/log/
echo ...Fertig
END=$(date +%s)
echo Total restore time: `date -u -d "0 $END seconds - $START seconds" +"%H:%M:%S"`
