#!/bin/bash
# fhem-backup.sh
# Carsten Söhrens, 25.05.2017

# set -x

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

### Löschen von Einträgen für Power, die älter als 7 Tage sind
$PSQL $DBNAME << EOF > $LOG 2>&1
delete from history where reading='power' and (timestamp < now() - interval '7 days');
select type, reading, count(*) from history group by type,reading order by type,reading;
select count(*) from history;
EOF

### Dump der Postgres-Datenbank
$PGDUMP -v -Fc --file=$DBTARGET $DBNAME >> $LOG 2>&1

### Archivieren der Config-Dateien
$ZIP -rv $ZIPTARGET /home/pi/docker/data/fhem/fhem.cfg >> $LOG 2>&1
$ZIP -rv $ZIPTARGET /home/pi/docker/data/fhem/db.conf >> $LOG 2>&1
$ZIP -rv $ZIPTARGET /home/pi/docker/data/fhem/www/gplot/myPlot_*.gplot >> $LOG 2>&1

### rsync nach morpheus
#$RSYNC -avz /home/pi/backup/ osmc@192.168.2.38:$REMOTE >> $LOG 2>&1
