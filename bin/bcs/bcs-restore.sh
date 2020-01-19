#!/bin/bash
# Name : bcs-restore.sh
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

if [[ "$MACHINE" == 'bcs' ]]; then
	DATABASE=172.16.1.103
else
	DATABASE=localhost
fi

PSQL="psql postgresql://bcs@$DATABASE/bcs"

LATESTBACKUP=`ls -tp /opt/projektron/bcs/restore/ | grep -v /$ | head -1`
BCSHOME=/opt/projektron/bcs/server

echo Shutdown BCS
$BCSHOME/bin/ProjektronBCS.sh stop

if [[ "$MACHINE" != 'bcs' ]]; then
	echo "Testserver-Restore: Emptying BCS log directory"
	rm -rf $BCSHOME/log/*
fi

echo Restoring /opt/projektron/bcs/restore/${LATESTBACKUP}
START=$(date +%s)
$BCSHOME/bin/Restore.sh -NoSIDCheck -n -i /opt/projektron/bcs/restore/${LATESTBACKUP}
END=$(date +%s)

if [[ "$MACHINE" != 'bcs' ]]; then
	echo "Testserver-Restore: Deactivate Exchange-Synchronisation for all users"
	$PSQL -c "UPDATE custattr_int SET value=0 WHERE attrib='syncAdapterActive';"
fi
	
echo Start BCS
$BCSHOME/bin/ProjektronBCS.sh start

echo ...Fertig
echo Restore time: `date -u -d "0 $END seconds - $START seconds" +"%H:%M:%S"`
