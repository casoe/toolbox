#!/bin/bash
# Name : next-stop.sh
# Autor: Carsten Söhrens

### Überprüfe, auf welcher Maschine das Skript ausgeführt wird
MACHINE=`uname -n`

if [[ "$MACHINE" == 'bcs' ]]; then
	echo "Abort" && exit 1
fi

START=$(date +%s)

echo Shutdown BCS...
/opt/projektron/bcs/server_next/bin/ProjektronBCS.sh stop

END=$(date +%s)

echo ...Fertig
echo Stop time: `date -u -d "0 $END seconds - $START seconds" +"%H:%M:%S"`
