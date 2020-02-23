#!/bin/bash
# Name : fhemdb_delete-totals-every-second.sh
# Autor: Carsten Söhrens

#set -x

PSQL="/usr/bin/psql"
DBNAME="postgresql://fhem@localhost:5432/fhem"
LOG="fhemdb_delete-totals-every-second.log"

# Redirect all output -> stdout ( > ) and stderr (2>&1) into a named pipe ( >() ) running "tee"
rm -f $LOG
exec > >(tee -ia $LOG)
exec 2>&1

# Kleinsten Tag in der Datenbank abfragen
DAY0=$($PSQL -X $DBNAME -t -c "select date_trunc('day', min(timestamp)) from history where reading='total_consumption';")

# Schleife von diesem kleinsten Tage bis heute (als epoch)
while [ $(date -d "$DAY0" "+%s") -lt $(date "+%s") ] ; do

	# Delete-Statement
	DELETE=$($PSQL -X $DBNAME -t -c "delete from history where date_trunc('minute', timestamp)= '$DAY0' and reading='total_consumption' and value !=(select max(value) from history where date_trunc('minute', timestamp)= '$DAY0');")
	
	# Ausgabe für das Log
	echo "$DAY0: $DELETE"

	# Tage einen Tag nach vorn schieben
	DAY0=$(date -d "$DAY0 1 day" "+%Y-%m-%d %H:%M:00")

done
