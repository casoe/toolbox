#!/bin/bash
# Name : daily-export-bcs2monlist-step2 (Umwandlung und Import der Daten in Monlist)
# Autor: Carsten Söhrens

### set var: current day of month
FULLDATE=`date +\%Y\%m\%d`
LOGFILE=/opt/projektron/bcs/export/${FULLDATE}.log

### Umwandeln der BCS-Exporte nach json für monapi
### (der bcs-export läuft separat per eigenem cronjob, weil er eine gewisse Zeit braucht, bis er fertig ist)
gb30-bcs-convert /opt/projektron/bcs/export/${FULLDATE}*.csv -o /opt/projektron/bcs/export/${FULLDATE}.tmp 2> $LOGFILE
jq '.|sort_by(.Nummer,.Tag,.Von)' /opt/projektron/bcs/export/${FULLDATE}.tmp > /opt/projektron/bcs/export/${FULLDATE}.json
rm -f /opt/projektron/bcs/export/${FULLDATE}.tmp

### Laden der Daten über monapi und Schreiben eines Log-Files
cd /opt/projektron/bcs/monlist
monapi import /opt/projektron/bcs/export/${FULLDATE}.json >> $LOGFILE
cat $LOGFILE >> /opt/projektron/bcs/server/log/daily-export-bcs2monlist.log

### Archivieren der erzeugten Dateien
cd /opt/projektron/bcs/export/
cp $LOGFILE /opt/projektron/bcs/monlist/log
zip -m /opt/projektron/bcs/monlist/archive/${FULLDATE}.zip ${FULLDATE}*

### Aufräumen des Export-Verzeichnisses
rm -rf /opt/projektron/bcs/export/*
