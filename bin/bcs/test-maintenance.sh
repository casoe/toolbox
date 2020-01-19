#!/bin/bash
# Name : test-maintenance.sh
# Autor: Carsten Söhrens

### Setting variables
SCRIPT="test-maintenance.sh"
MACHINE=`uname -n`
BCSHOME="/opt/projektron/bcs/server"

### Check if it's the live server, if so abort
if [[ "$MACHINE" = 'bcs' ]]; then
	echo "This is the live server. Abort!" && exit 1
fi

### Shutdown BCS
$BCSHOME/bin/ProjektronBCS.sh stop

### Start maintenance web server
cd $BCSHOME/inform_maintenance
((python3 simple_http_server.py) & jobs -p > pidfile)
read -p "Press any key to end maintenance mode and restart BCS...`echo $'\n> '`"
kill -9 `cat $BCSHOME/inform_maintenance/pidfile`

### Bring BCS online again
$BCSHOME/bin/ProjektronBCS.sh start
