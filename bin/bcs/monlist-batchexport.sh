#!/bin/bash
# Name : monlist-exportbatch.sh
# Autor: Carsten Söhrens

### Allgemeine Variablen
TODAY=`date +"%d.%m.%Y"`
source monlist-startdate.cfg
MONTHS=$(( (`date +%Y`-`date -d $STARTDATE +"%Y"`)*12 + `date +%-m`-`date -d $STARTDATE +"%-m"`))
SCHEDULERCLIENT="/opt/projektron/bcs/server/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ExportJob"


function wait_for_cpu_usage {
    threshold=$1
    while true ; do
        # Get the current CPU usage
        usage=$(top -n1 | awk 'NR==3{print $2}' | tr ',' '.')
		echo $usage

        # Compared the current usage against the threshold
        result=$(bc -l <<< "$usage <= $threshold")
        if [ $result == "1" ]; then
			break
		fi

        # Feel free to sleep less than a second. (with GNU sleep)
        sleep 1
    done
    return 0
}

function wait_for_file {
	file=$1
	change=0

    while true ; do
        # Get the file size
		if [ -f $file ];
			then
				usage=$(du $file | awk 'NR==1{print $1}')
			else
				usage=0
		fi

        # Check if file bigger 0
		if [ $usage -gt "0" ] && [ $usage == $change ]; then
			break
		fi

		let change=usage
        sleep 1

	done
return 0
}

### Wechsel in das Arbeitsverzeichnis, Abräumen der bisherigen Daten
cd /opt/projektron/bcs/monlist
rm -rf /opt/projektron/bcs/monlist/exports/*
rm -rf /opt/projektron/bcs/monlist/json/*

### Schleife, um durch die relevanten Monate zu laufen
COUNTER=0
while [  $COUNTER -lt $MONTHS ]; do

	### Relevante Datumsangaben für den jeweiligen Monat und Name des Zielordners berechnen
	### 01.01.2016
	PARAM1=`date -d "$STARTDATE +$COUNTER month" +"%d.%m.%Y"`
	### 31.01.2016
	PARAM2=`date -d "$STARTDATE +$(($COUNTER+1)) month -1 day" +"%d.%m.%Y"`
	### 2016-01
	FOLDER=`date -d "$STARTDATE +$COUNTER month" +"%Y-%m"`


	### Ein bisschen Ausgabe, was wir gerade machen
	echo Processing $FOLDER

	### Triggern der Exporte über den Scheduler-Client
	$SCHEDULERCLIENT -t CSV_Monlist_Allowances_Batch  "export.param.startdate=$PARAM1" "export.param.enddate=$PARAM2"
	$SCHEDULERCLIENT -t CSV_Monlist_Appointment_Batch "export.param.startdate=$PARAM1" "export.param.enddate=$PARAM2"
	$SCHEDULERCLIENT -t CSV_Monlist_DeputatUser_Batch "export.param.startdate=$PARAM1" "export.param.enddate=$PARAM2"
	$SCHEDULERCLIENT -t CSV_Monlist_Efforts_Batch     "export.param.startdate=$PARAM1" "export.param.enddate=$PARAM2"

	### Zielverzeichnis anlegen
	mkdir -p exports/$FOLDER/

	### Warten, dass alle Dateien fertig geschrieben sind (siehe Funktion)

	echo -n Waiting for exports to finish...
	time=$((`date +"%s"`))
	wait_for_file exports/Export_Allowances.csv
	wait_for_file exports/Export_Appointment.csv
	wait_for_file exports/Export_DeputatUser.csv
	wait_for_file exports/Export_Efforts.csv
	time=$(( `date +"%s"` - $time ))
	echo " " $time sec

	### Nochmal sicherheitshalber 5 sec warten
	sleep 5

	### Verschieben der Exporte in die Zielverzeichnisse
	mv exports/*.csv exports/$FOLDER/

	let COUNTER+=1
done

### Counter zurücksetzen und nochmal über alle Files iterieren, um json zu erzeugen
COUNTER=0

while [  $COUNTER -lt $MONTHS ]; do

	### Dateiname berechnen
	FILE=`date -d "$STARTDATE +$COUNTER month" +"%Y-%m"`

	echo Create $FILE...

	### Konvertierung durchführen
	gb30-bcs-convert exports/$FILE/*.csv -o temp.json && jq '.|sort_by(.Nummer,.Tag,.Von)' temp.json > json/$FILE.json
	rm temp.json

	let COUNTER+=1

done
