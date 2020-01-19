#!/bin/bash
# Name : monlist-jsongenerate.sh
# Autor: Carsten Söhrens

### Allgemeine Variablen
TODAY=`date +"%d.%m.%Y"`
STARTDATE="2019-07-01"
MONTHS=$(( (`date +%Y`-`date -d $STARTDATE +"%Y"`)*12 + `date +%-m`-`date -d $STARTDATE +"%-m"`))
WORKDIR=/opt/projektron/bcs/monlist

# Wechsel in das Arbeitsverzeichnis
cd $WORKDIR

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
