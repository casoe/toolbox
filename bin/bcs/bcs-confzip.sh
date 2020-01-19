#!/bin/bash
# Name : bcs-confzip.sh
# Autor: Carsten Söhrens

### set var: current day of month
FULLDATE=`date +\%Y-\%m-\%d`

### Lösche altes Backup sofern vorhanden
rm -f /opt/projektron/bcs/backup/conf_${FULLDATE}.zip

### Erstelle Backup und schreibe Log in Datei
echo Backup in /opt/projektron/bcs/backup/conf_${FULLDATE}.zip
cd /opt/projektron/bcs/server
zip -r /opt/projektron/bcs/backup/conf_${FULLDATE}.zip conf/
zip -r /opt/projektron/bcs/backup/conf_${FULLDATE}.zip conf_local_live/
zip -r /opt/projektron/bcs/backup/conf_${FULLDATE}.zip conf_local_test/

echo ...Fertig
