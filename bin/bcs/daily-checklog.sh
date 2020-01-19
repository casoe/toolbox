#!/bin/bash
# Name : bcs-checklog.sh
# Autor: Carsten Söhrens

FULLDATE=`date +\%Y-\%m-\%d`
BCSLOGDIR="/opt/projektron/bcs/server/log"

### Suche nach erschöpften Lizenzen aus dem Pool
### daily-check.log wird geleert bzw. neu begonnen
grep $FULLDATE $BCSLOGDIR/logins.log |grep 'internal.LicenseTracker WARN' > $BCSLOGDIR/daily-check.log

### Check auf fehlende Personalnummern in Monlist beim Export/Upload der Daten
if grep -q 'Kein Personaleintrag gefunden' $BCSLOGDIR/daily-export-bcs2monlist.log; then
	echo 'ACHTUNG: Fehler im Monlist-Interface' >> $BCSLOGDIR/daily-check.log
	grep 'Kein Personaleintrag gefunden' $BCSLOGDIR/daily-export-bcs2monlist.log >> $BCSLOGDIR/daily-check.log
fi

### Check auf Probleme bei der Umwandlung der Daten für Monlist
if grep -q 'Invalid Record' $BCSLOGDIR/daily-export-bcs2monlist.log; then
	echo 'ACHTUNG: Fehler im Monlist-Interface' >> $BCSLOGDIR/daily-check.log
	grep 'Invalid Record' $BCSLOGDIR/daily-export-bcs2monlist.log >> $BCSLOGDIR/daily-check.log
fi

### Check, ob das Backup-Log den String ERROR enthält
if grep -q 'ERROR' $BCSLOGDIR/daily-backup.log; then
  echo 'ACHTUNG: Fehler beim Daily-Backup' >> $BCSLOGDIR/daily-check.log
	cat $BCSLOGDIR/daily-backup.log >> $BCSLOGDIR/daily-check.log
fi

### Check, ob das PDI-Logfile Zeilen mit Excel UND Error beinhaltet
if grep -q 'Excel.*ERROR' $BCSLOGDIR/daily-export-pdi2ods.log; then
  echo 'ACHTUNG: Fehler beim der Pentaho-Datenintegration' >> $BCSLOGDIR/daily-check.log
	grep 'Excel.*ERROR' $BCSLOGDIR/daily-export-pdi2ods.log >> $BCSLOGDIR/daily-check.log
fi

### Filegröße von daily-check.log in Variable schreiben
USAGE=$(du $BCSLOGDIR/daily-check.log | awk 'NR==1{print $1}')

### Wenn etwas drin steht (Filegröße größer 0), dann per Email an bcs-support senden
if [ $USAGE -gt "0" ]; then
	cat $BCSLOGDIR/daily-check.log | mail -E -s "[Alert] BCS Checklog enthaelt Meldungen" "bcs-support@inform-software.com"
fi
