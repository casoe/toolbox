#!/bin/bash
# Zweck: Export der Ist-Sachkosten in eine csv-Datei für DATEV
# Autor: Jan-Michael Regulski

exec > /opt/projektron/bcs/export/EffortFixed_ExportSplitMail.log 2>&1

SCRIPT="export-effortsfixed-datev-gb30.sh"
BCSHOME="/opt/projektron/bcs/server"
SCRIPTDIR="$BCSHOME/inform_scripts"
BCSEXPORT="/opt/projektron/bcs/export"
BCSARCHIV="/opt/projektron/bcs/datev"
PYTHON="/usr/bin/python3"


exortfileprefix="BCS2DATEV_EffortsFixed_gb30_"
schedulerdef="CSV_DATEV_EffortsFixed_GB3-INFORM-Cronjob"
gb30sekmail="jan-michael.regulski@inform-software.com"

FULLDATE=$(date +"%Y-%-m-%-d")
FULLTIME=$(date +"%H-%M")
mailsubject="$FULLDATE, BCS-Ist-Sachkosten für den Import nach DATEV"
mailcontent="Liste der freigegebenen Ist-Sachkosten, die in Datev importiert werden müssen."


### Start SchedulerClient for Export
echo Starte Export...
$BCSHOME/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ExportJob -t $schedulerdef

### Wait for 60 seconds
sleep 60s

### Split export file according to year and month of Datum field
pushd $BCSEXPORT
$PYTHON $SCRIPTDIR/FileSplitterByField.py $exortfileprefix$FULLDATE.csv Datum date

### Wait for finishing python script
wait $!

### Send to gb30-sek
# Collecting all created files for mail
attach_list=""
for filename in "$exortfileprefix$FULLDATE"_*.csv; do
  attach_list="$attach_list $filename "
done
echo $mailcontent | mutt -F "$BCSARCHIV/.muttrc" -s "$mailsubject" -e "set crypt_use_gpgme=no" -a $attach_list -- "$gb30sekmail"
popd

### Copy Export files to archive directory, adding time in case of several jobs per day
### Zipping and moving of the files in the export directory directly into achive directory
zip -r -m -j $BCSARCHIV/archiv-ist-sachkosten/$exortfileprefix$FULLDATE-$FULLTIME.zip $BCSEXPORT

echo ...Fertig