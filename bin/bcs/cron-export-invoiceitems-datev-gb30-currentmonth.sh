#!/bin/bash
# Zweck: Export der Rechnungspositionen in eine csv-Datei für DATEV
# Autor: Jan-Michael Regulski

SCRIPT="export-invoiceitems-datev-gb30-currentmonth.sh"
BCSHOME="/opt/projektron/bcs/server"
BCSEXPORT="/opt/projektron/bcs/export"
BCSARCHIV="/opt/projektron/bcs/datev"

exortfileprefix="BCS2DATEV_InvoiceItems_AktuellerMonat_gb30_"
schedulerdef="CSV_DATEV_InvoiceItems_GB3_CurrentMonth-INFORM-Cronjob"
gb30sekmail="GB30-SEK@inform-software.com"

FULLDATE=$(date +"%Y-%-m-%-d")
FULLTIME=$(date +"%H-%M")
mailsubject="$FULLDATE, BCS-Rechnungspositionen für den Import nach DATEV"
mailcontent="Liste der Rechnungspositionen von abgeschlossenen, bisher nicht exportierten Rechnungen, die in Datev importiert werden müssen."


### Start SchedulerClient for Export
echo Starte Export...
$BCSHOME/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ExportJob -t $schedulerdef

### Wait for 60 seconds
sleep 60s

### Send to gb30-sek
echo $mailcontent | mutt -F "$BCSARCHIV/.muttrc" -s "$mailsubject" -a "$BCSEXPORT/$exortfileprefix$FULLDATE.csv" -e "set crypt_use_gpgme=no" -- "$gb30sekmail"

### Copy Export file to archive directory, adding time in case of several jobs per day
### Aufräumen des Export-Verzeichnisses durch Verschieben
mv -f -v $BCSEXPORT/$exortfileprefix$FULLDATE.csv $BCSARCHIV/archiv-rechnungspositionen/$exortfileprefix$FULLDATE-$FULLTIME.csv


echo ...Fertig