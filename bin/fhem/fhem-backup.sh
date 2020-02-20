#!/bin/bash
# fhem-backup.sh
# Carsten Söhrens, 25.05.2017

# set -x

# Historie
# 2020-01-06 Umstellung auf neue Ordnerstruktur und Sync mit dem NAS statt mit OSMC
# 2020-01-07 Stoppen der Zeit ergänzt

PGDUMP="/usr/bin/pg_dump"
PSQL="/usr/bin/psql"
ZIP="/usr/bin/zip"
DBNAME="postgresql://fhem:fhem@localhost:5432/fhem"
TODAY=`date +"%Y-%m-%d"`
LOG="/home/pi/backup/log/db_backup_$TODAY.log"
DBTARGET="/home/pi/backup/db/db_backup_$TODAY.sqlc"
ZIPTARGET="/home/pi/backup/conf/fhem_backup_$TODAY.zip"
RSYNC="/usr/bin/rsync"

# Startzeit speichern
START=$(date +%s)

### Löschen von Einträgen für Power, die älter als 7 Tage sind
$PSQL $DBNAME << EOF > $LOG 2>&1
delete from history where reading='ENERGY_Power' and (timestamp < now() - interval '7 days');
delete from history where reading='power' and (timestamp < now() - interval '7 days');
delete from history where type='SYSSTAT' and (timestamp < now() - interval '30 days');
select type, reading, count(*) from history group by type,reading order by type,reading;
select count(*) from history;
EOF

### Dump der Postgres-Datenbank
$PGDUMP -v -Fc --file=$DBTARGET $DBNAME >> $LOG 2>&1

### Wiederherstellen-Hinweis im Logfile
echo "Wiederherstellen: pg_restore -Fc --clean --no-acl --no-owner -h localhost -U fhem -d fhem -C $DBTARGET" >> $LOG 2>&1

### Archivieren des Skripts und der Config-Dateien
$ZIP -rv $ZIPTARGET /home/pi/bin/fhem-backup.sh >> $LOG 2>&1
$ZIP -rv $ZIPTARGET /opt/fhem/fhem.cfg >> $LOG 2>&1
$ZIP -rv $ZIPTARGET /opt/fhem/db.conf >> $LOG 2>&1
$ZIP -rv $ZIPTARGET /home/pi/.bash_history >> $LOG 2>&1
$ZIP -rv $ZIPTARGET /opt/fhem/www/gplot/myPlot*.gplot >> $LOG 2>&1

### rsync zum NAS
if [ ! $(mount | grep -o /mnt/backup ) ]; then
  mount /mnt/backup
fi
sudo $RSYNC -avht --update /home/pi/backup/ /mnt/backup/hades/fhem  >> $LOG 2>&1
umount /mnt/backup

### Backup-Zeit ausgeben
echo Backup time: `date -u -d "0 $(date +%s) seconds - $START seconds" +"%H:%M:%S"` >> $LOG 2>&1
