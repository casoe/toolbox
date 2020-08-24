#!/bin/bash
# Name : monlist-jsonstrip.sh
# Autor: Carsten Söhrens

if [ -z $1 ]
then
  echo Personalnummer fehlt
  exit
fi

### Allgemeine Variablen
TODAY=`date +"%d.%m.%Y"`
source monlist-startdate.cfg
MONTHS=$(( (`date +%Y`-`date -d $STARTDATE +"%Y"`)*12 + `date +%-m`-`date -d $STARTDATE +"%-m"`))
WORKDIR=/opt/projektron/bcs/monlist

COUNTER=0
NUMBER=$1

cd $WORKDIR

echo "Erzeuge einzelne json-Dateien für $NUMBER"

while [  $COUNTER -lt $MONTHS ]; do

	### Relevante Datumsangaben für den jeweiligen Monat berechnen
	FOLDER=`date -d "$STARTDATE +$COUNTER month" +"%Y-%m"`


	TARGET=$FOLDER
	TARGET+=_
	TARGET+=$NUMBER

	echo Create json/$TARGET.json

	### Filterung der relevanten Information und Schreiben in eine einzelne Datei
	cat json/$FOLDER.json | jq ".[] | select(.Nummer==$NUMBER)" > json/$TARGET.json

	let COUNTER+=1

done
