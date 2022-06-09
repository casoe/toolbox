#!/bin/bash
# Autor: Carsten Söhrens

TODAY=`date +\%Y-\%m-\%d`
YDA=`date -d "1 day ago" +\%Y-\%m-\%d`
BCSLOGDIR="/opt/projektron/bcs/server/log/inform_cron"
AWK=/usr/bin/awk

#set -x

# daily-check.log wird abgeräumt
rm -f $BCSLOGDIR/daily-check.log

### AB HIER KOMMEN ALLE CHECKS
# Suche nach erschöpften Lizenzen aus dem Pool
if [[ $(grep $YDA $BCSLOGDIR/../cti.log |grep 'exhausted') ]]; then
	echo 'ACHTUNG: Lizenzpool für bestimmte Lizenzen erschöpft' >> $BCSLOGDIR/daily-check.log
	grep $YDA $BCSLOGDIR/../cti.log |grep 'exhausted' >> $BCSLOGDIR/daily-check.log
fi

# Check auf fehlende Personalnummern in Monlist beim Export/Upload der Daten
if grep -q 'Kein Personaleintrag gefunden' $BCSLOGDIR/daily-export-bcs2monlist.log; then
	echo 'ACHTUNG: Fehler im Monlist-Interface' >> $BCSLOGDIR/daily-check.log
	grep 'Kein Personaleintrag gefunden' $BCSLOGDIR/daily-export-bcs2monlist.log >> $BCSLOGDIR/daily-check.log
fi

# Check auf Probleme bei der Umwandlung der Daten für Monlist
if grep -q 'Invalid Record' $BCSLOGDIR/daily-export-bcs2monlist.log; then
	echo 'ACHTUNG: Fehler im Monlist-Interface' >> $BCSLOGDIR/daily-check.log
	grep 'Invalid Record' $BCSLOGDIR/daily-export-bcs2monlist.log >> $BCSLOGDIR/daily-check.log
fi

# Check, ob das Backup-Log den String ERROR enthält
if grep -q 'ERROR' $BCSLOGDIR/daily-backup.log; then
  echo 'ACHTUNG: Fehler beim Daily-Backup' >> $BCSLOGDIR/daily-check.log
	cat $BCSLOGDIR/daily-backup.log >> $BCSLOGDIR/daily-check.log
fi

# Check, ob das PDI-Logfile Zeilen mit Excel UND Error beinhaltet
if grep -q 'Excel.*ERROR' $BCSLOGDIR/daily-export-pdi2ods.log; then
  echo 'ACHTUNG: Fehler beim der Pentaho-Datenintegration' >> $BCSLOGDIR/daily-check.log
	grep 'Excel.*ERROR' $BCSLOGDIR/daily-export-pdi2ods.log >> $BCSLOGDIR/daily-check.log
fi

# Check, ob der Job ResynchEfforts Probleme hatte
if [[ $(grep $TODAY $BCSLOGDIR/../bcs-application-detailed.log |grep 'Err_ResynchEffortsHadErrors') ]]; then
	echo 'ACHTUNG: Lizenzpool für bestimmte Lizenzen erschöpft' >> $BCSLOGDIR/daily-check.log
	grep $TODAY $BCSLOGDIR/../bcs-application-detailed.log |grep 'Err_ResynchEffortsHadErrors' >> $BCSLOGDIR/daily-check.log
fi

# Check, ob Reports wegen fehlender Rechte nicht versendet wurden
if [[ $(grep $TODAY $BCSLOGDIR/../cron/GenerateScheduledReports.out |grep 'was not sent') ]]; then
	echo 'ACHTUNG: Reports wurden wegen fehlender Rechte nicht versendet' >> $BCSLOGDIR/daily-check.log
	grep $TODAY $BCSLOGDIR/../cron/GenerateScheduledReports.out |grep 'was not sent' >> $BCSLOGDIR/daily-check.log
fi

# Check, ob die DATEV-Exporte zu alt sind (>5 Tage)
if [[ $(grep $TODAY $BCSLOGDIR/daily-export-pdi2ods-statistics.csv |$AWK -F ';' '$6>5') ]]; then
	echo 'ACHTUNG: DATEV-Exporte veraltet (>5 Tage)' >> $BCSLOGDIR/daily-check.log
	grep $TODAY $BCSLOGDIR/daily-export-pdi2ods-statistics.csv | $AWK -F ';' '$6>5' | column -t -s $';' -n "$@" >> $BCSLOGDIR/daily-check.log
fi

### AB HIER KOMMT DIE NACHVERARBEITUNG
# Filegröße von daily-check.log in Variable schreiben
USAGE=$(du $BCSLOGDIR/daily-check.log | awk 'NR==1{print $1}')

# Wenn etwas drin steht (Filegröße größer 0), dann per Email an bcs-support senden
if [ $USAGE -gt "0" ]; then
	cat $BCSLOGDIR/daily-check.log | mail -E -s "[Alert] BCS Checklog enthaelt Meldungen" "bcs-support@inform-software.com"
fi
