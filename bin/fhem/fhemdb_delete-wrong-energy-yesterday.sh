#!/bin/bash
# Name : fhemdb_delete-wrong-energy-yesterday.sh
# Autor: Carsten Söhrens

#set -x

PSQL="/usr/bin/psql"
DBNAME="postgresql://fhem@localhost:5432/fhem"
LOG="fhemdb_delete-wrong-energy-yesterday.log"

# Redirect all output -> stdout ( > ) and stderr (2>&1) into a named pipe ( >() ) running "tee"
rm -f $LOG
exec > >(tee -ia $LOG)
exec 2>&1

# Kleinsten Tag in der Datenbank abfragen
#DAY0=$($PSQL -X $DBNAME -t -c "select date_trunc('day', min(timestamp)) from history where device='MQTT2_DVES_0371A9' and reading='ENERGY_Yesterday';")

# Tag vor 10 Tagen berechnen
DAY0=$(date -d "10 days ago" "+%Y-%m-%d 00:00:00")

# Schleife von diesem Tag bis heute (als epoch)
while [ $(date -d "$DAY0" "+%s") -lt $(date "+%s") ] ; do

	# Delete-Statement
	DELETE=$($PSQL -X $DBNAME -t -c "delete from history where date_trunc('day', timestamp)= '$DAY0' and device = 'MQTT2_DVES_0371A9' and reading = 'ENERGY_Yesterday' and timestamp !=(select min(timestamp) from history where date_trunc('day', timestamp)= '$DAY0' and device = 'MQTT2_DVES_0371A9' and reading = 'ENERGY_Yesterday');")
	
	# Ausgabe für das Log
	echo "$DAY0: $DELETE"

	# Tage einen Tag nach vorn schieben
	DAY0=$(date -d "$DAY0 1 day" "+%Y-%m-%d %H:%M:00")

done
