#!/bin/bash
# Autor: Carsten Söhrens

### Überprüfe, auf welcher Maschine das Skript ausgeführt wird
### Abbruch, sofern es sich um das Live-System handelt
MACHINE=`uname -n`

if [[ "$MACHINE" == 'bcs' ]]; then
	echo "This is the live server. Abort!" && exit 1
else
	DATABASE=localhost
fi

BCSHOME=/opt/projektron/bcs/server
LOG=$BCSHOME/specific-restore.log
PGDUMP=/usr/bin/pg_dump
PGRESTORE=/usr/bin/pg_restore
FULLDATE=`date +\%Y-\%m-\%d`
PSQL="psql postgresql://bcs@$DATABASE/bcs"

# Redirect stdout ( > ) and stderr (2>&1) into a named pipe ( >() ) running "tee"
exec > >(tee -ia $LOG)
exec 2>&1

START=$(date +%s)

echo Shutdown BCS-Test
$BCSHOME/bin/ProjektronBCS.sh stop

if [[ "$MACHINE" != 'bcs' ]]; then
	echo "Testserver-Restore: Emptying BCS log directory"
	rm -rf $BCSHOME/log/*
fi

### Es werden alle Tabellen gedropped; sofern schon eine neue Version auf Next installiert war,
### lässt sich diese ansonsten nicht starten, weil der Datenbankmanager beim Anlegen neuer
### Tabellen crashed (diese sind schon vorhanden und werden bei pg_restore nicht gedropped)
$PSQL -t -c "select 'drop table \"' || tablename || '\" cascade;' from pg_tables where schemaname='public'" | $PSQL

echo Spiegelung des Data-Verzeichnisses und des DB-Backups vom Live-Server mit rsync
mkdir -p $BCSHOME/../restore/db
rsync -avP --delete  root@172.16.1.101:/mnt/backup/bcsbackup_2020-04-29/files/ $BCSHOME/data/files
rsync -avP --delete  root@172.16.1.101:/mnt/backup/bcsbackup_2020-04-29/db/ $BCSHOME/../restore/db

echo Volltestindex löschen, wird dann bei Neustart neu erzeugt
rm -rf $BCSHOME/data/FTIndex/*

echo Restore auf DB
$PGRESTORE -v -j 12 -w -n public -h localhost -p 5432 -d bcs -U bcs -Fd $BCSHOME/../restore/db/

if [[ "$MACHINE" != 'bcs' ]]; then
	echo "Testserver-Restore: Deactivate Exchange-Synchronisation for all users"
	$PSQL -c "UPDATE custattr_int SET value=0 WHERE attrib='syncAdapterActive';"
fi

$BCSHOME/bin/Restore.sh -rmserverid

echo Start BCS
$BCSHOME/bin/ProjektronBCS.sh start

mv $LOG $BCSHOME/log/
echo ...Fertig
END=$(date +%s)
echo Total restore time: `date -u -d "0 $END seconds - $START seconds" +"%H:%M:%S"`
