#!/bin/bash
# Name : test-workday.sh
# Autor: Carsten Söhrens

COUNTER=0
TO=`date +%d`
let TO=TO-1
WORKDAY=0
MONTH=`date +%Y-%m-`01
DEBUG=true

# Schleife, die alle Tage bis einschließlich gestern durchläuft
while [ $COUNTER -lt $TO ]; do
	DATE=`date -d "$MONTH +$COUNTER days" +%Y-%m-%d`
	WEEKDAY=`date +%w -d $DATE`
	HOLIDAY=`calendar -l 0 -f /opt/projektron/bcs/server/inform_scripts/calendar.bcs -t $DATE`

	if [ $DEBUG == "true" ]; then
		echo -n $DATE $WEEKDAY $HOLIDAY
	fi 
	
	# Durchlaufen der Schleife nur, wenn der Wochentag des Datums ungleich Samstag und Sonntag ist
	if [ $WEEKDAY -gt 0 ] && [ $WEEKDAY -lt 6 ]; then
		# Wenn HOLIDAY nicht leer (also Feiertag), dann Zählen als Werktag überspringen
		if [ -z "$HOLIDAY" ]; then
			let WORKDAY=WORKDAY+1 
			if [ $DEBUG == "true" ]; then
				echo -n "" Arbeitstag $WORKDAY
			fi
		fi
	fi
	
	# Counter der Schleife hochzählen
	let COUNTER=COUNTER+1 
	
	if [ $DEBUG == "true" ]; then
		echo
	fi
  
done

# Ausgabe der Arbeitstage bis gestern
echo $WORKDAY
