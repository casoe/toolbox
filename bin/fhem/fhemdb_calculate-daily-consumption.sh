#!/bin/bash
# fhemdb_calculate-daily-consumption.sh
# Carsten Söhrens, 22.02.2020

#set -x

PSQL="/usr/bin/psql"
DBNAME="postgresql://fhem@localhost:5432/fhem"

# Kleinsten Tag in der Datenbank abfragen
DAY0=$($PSQL -X $DBNAME -t -c "select date_trunc('day', min(timestamp)) from history where reading='total_consumption';")

# Start ist ab heute und dann rückwärts in der Zeit
DAY1=$(date "+%Y-%m-%d 00:00:00")

# Abfragefenster ab heute -1 und heute -2 anpassen
DAY1=$(date -d "$DAY1 1 day ago" "+%Y-%m-%d %H:%M:00")
DAY2=$(date -d "$DAY1 1 day ago" "+%Y-%m-%d %H:%M:00")

# Erste Abfrage durchführen
TOTAL1=$($PSQL -X $DBNAME -t -c "select value from history where date_trunc('day', timestamp)= '$DAY1' and reading = 'total_consumption' and timestamp =( select max(timestamp) from history where date_trunc('day', timestamp)= '$DAY1' and reading = 'total_consumption');")

# Schleife von heute bis zu diesem kleinsten Tage (als epoch)
while [ $(date -d "$DAY2" "+%s") -gt $(date -d "$DAY0" "+%s") ] ; do

	# Den Wert für den Tag davor (DAY2) abfragen
	TOTAL2=$($PSQL -X $DBNAME -t -c "select value from history where date_trunc('day', timestamp)= '$DAY2' and reading = 'total_consumption' and timestamp =( select max(timestamp) from history where date_trunc('day', timestamp)= '$DAY2' and reading = 'total_consumption');")


	# Verbrauch berechnen
	CONSUMPTION=$(bc <<< "$TOTAL1-$TOTAL2")


	# Insert-Statement zusammenbauen
	echo "insert into history (timestamp, device, type, event, reading, value, unit) values ('$(date -d "$DAY1" "+%Y-%m-%d 23:59:59")', 'Stromzaehler', 'OBIS', 'daily_consumption: $CONSUMPTION', 'daily_consumption', $CONSUMPTION, '');"

	# Den Wert von Tag -2 in Tag -1 speichern (dann muss nur eine SQL-Abfrage gemacht werden)
	TOTAL1=$TOTAL2

	# Das Abfragefenster einen Tag nach hinten schieben
	DAY1=$(date -d "$DAY1 1 day ago" "+%Y-%m-%d %H:%M:00")
	DAY2=$(date -d "$DAY1 1 day ago" "+%Y-%m-%d %H:%M:00")

done
