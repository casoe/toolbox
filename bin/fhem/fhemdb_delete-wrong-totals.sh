#!/bin/bash
# fhemdb_delete-wrong_totals.sh
# Carsten Söhrens, 23.02.2020

#set -x

PSQL="/usr/bin/psql"
DBNAME="postgresql://fhem@localhost:5432/fhem"
LOG="fhemdb_delete-wrong_totals.log"

# Redirect all output -> stdout ( > ) and stderr (2>&1) into a named pipe ( >() ) running "tee"
rm -f $LOG
exec > >(tee -ia $LOG)
exec 2>&1

# Kleinsten Tag in der Datenbank abfragen; das ist der Start für die Iteration über alle Datensätze
DAY0=$($PSQL -X $DBNAME -t -c "select date_trunc('day', min(timestamp)) from history where reading='total_consumption';")
# Spezifisches Datum (bis zu diesem Datum waren mehrfach kaputte Datensätez vorhanden)
UNTIL='2018-01-31 00:00:00'
# oder Enddatum heute
#UNTIL=$(date "+%Y-%m-%d 00:00:00")

# Schleife von diesem kleinsten Tage bis heute (zum Rechnen als Epoch-> %s)
while [ $(date -d "$DAY0" "+%s") -lt $(date -d "$UNTIL" "+%s") ] ; do

	# Delete-Statement für unplausible Minimalwerte
	DELETE1=$($PSQL -X $DBNAME -t -c "delete from history where value::decimal < (select value from history where date_trunc('day', timestamp)= '$DAY0' and reading = 'total_consumption' and timestamp =( select min(timestamp) from history where date_trunc('day', timestamp)= '$DAY0' and reading = 'total_consumption' ))::decimal and date_trunc('day', timestamp)= '$DAY0' and reading = 'total_consumption';")
	
	# Delete-Statement für unplausible Maximalwerte
	DELETE2=$($PSQL -X $DBNAME -t -c "delete from history where value::decimal > (select value from history where date_trunc('day', timestamp)= '$DAY0' and reading = 'total_consumption' and timestamp =( select max(timestamp) from history where date_trunc('day', timestamp)= '$DAY0' and reading = 'total_consumption' ))::decimal and date_trunc('day', timestamp)= '$DAY0' and reading = 'total_consumption';")

	# Ausgabe für das Log
	echo "Min $DAY0: $DELETE1"
	echo "Max $DAY0: $DELETE2"

	# Tage einen Tag nach vorn schieben
	DAY0=$(date -d "$DAY0 1 day" "+%Y-%m-%d %H:%M:00")

done