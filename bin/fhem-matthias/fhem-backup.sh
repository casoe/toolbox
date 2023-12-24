#!/bin/bash
# fhem-backup.sh
# Carsten Söhrens, 25.05.2017

# set -x

HOME="/home/pi"
PGDUMP="/usr/bin/pg_dump"
PSQL="/usr/bin/psql"
ZIP="/usr/bin/zip"
DBNAME="postgresql://fhem@localhost:5432/fhem"
TODAY=`date +"%Y-%m-%d"`
LOG="/home/pi/backup/log/fhem_backup_$TODAY.log"
DBTARGET="/home/pi/backup/db/db_backup_$TODAY.sqlc"
ZIPTARGET="/home/pi/backup/conf/fhem_backup_$TODAY.zip"
REMOTE="/mnt/hd2tb/other/backup/hades"
RSYNC="/usr/bin/rsync"

### Check der Einträge in der Datenbank und Ausgabe ins Logfile
$PSQL $DBNAME << EOF > $LOG 2>&1
select type, reading, count(*) from history group by type,reading order by type,reading;
select count(*) from history;
EOF

### Dump der Postgres-Datenbank
$PGDUMP -v -Fc --file=$DBTARGET $DBNAME >> $LOG 2>&1

### Archivieren der Config-Dateien
$ZIP -rv $ZIPTARGET $HOME/fhem-docker/fhem/fhem.cfg >> $LOG 2>&1
$ZIP -rv $ZIPTARGET $HOME/fhem-docker/fhem/db.conf >> $LOG 2>&1
$ZIP -rv $ZIPTARGET $HOME/fhem-docker/fhem/www/gplot/myPlot_*.gplot >> $LOG 2>&1

### Löschen aller lokalen Dateien von Tag -15 bis -30
echo "INFO Löschen veralteter lokaler Dateien"
find $HOME/backup/ -name "*backup*" -type f -mtime +30 -delete  >> $LOG 2>&1
find $HOME/fhem-docker/fhem/log -name "fhem-*.log" -type f -mtime +30 -delete  >> $LOG 2>&1

### rsync nach morpheus
#$RSYNC -avz /home/pi/backup/ osmc@192.168.2.38:$REMOTE >> $LOG 2>&1
