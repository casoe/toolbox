#!/bin/bash -x
# Name : test-hooks.sh
# Autor: Carsten Söhrens

### Setting variables
MACHINE=`uname -n`
BCSHOME="/opt/projektron/bcs/server"

### Check if it's the test server, otherwise abort
if [[ "$MACHINE" == 'gs3-bcs' ]]; then
	echo "This is the live server. Abort!" && exit 1
fi

### Shutdown BCS
$BCSHOME/bin/ProjektronBCS.sh stop

### Hooks for special daily maintenance
sh      /opt/projektron/bcs/server/inform_scripts/daily-hooks
rm -rf  /opt/projektron/bcs/server/inform_scripts/daily-hooks
touch   /opt/projektron/bcs/server/inform_scripts/daily-hooks

### Restart BCS
$BCSHOME/bin/ProjektronBCS.sh start
