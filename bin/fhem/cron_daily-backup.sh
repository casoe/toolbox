#!/bin/bash
# fhem-backup.sh
# Carsten Söhrens, 25.05.2017

# set -x

# Historie
# 06.01.2020 Umstellung auf neue Ordnerstruktur und Sync mit dem NAS statt mit OSMC
# 07.01.2020 Stoppen der Zeit ergänzt
# 23.05.2020 Fix in Bezug auf mount mit sudo
# 25.05.2020 Fix an Permissions-Error für rsync; delete backups older than 14 days locally

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
echo "Wiederherstellen: pg_restore -Fc -v --clean -h localhost -U fhem -d fhem $DBTARGET" >> $LOG 2>&1

### Archivieren des Skripts und der Config-Dateien
$ZIP -rv $ZIPTARGET /opt/fhem/fhem.cfg >> $LOG 2>&1
$ZIP -rv $ZIPTARGET /opt/fhem/db.conf >> $LOG 2>&1
$ZIP -rv $ZIPTARGET /home/pi/.bash_history >> $LOG 2>&1
$ZIP -rv $ZIPTARGET /opt/fhem/www/gplot/myPlot*.gplot >> $LOG 2>&1
$ZIP -rv $ZIPTARGET /opt/fhem/www/tablet/index.html >> $LOG 2>&1

### Rotation: Delete backups older than 14 days locally
echo "### Rotation: Delete backups older than 5 days"
### For the sake of comprehensiveness try to delete everything from today -15 to today -30
### days
for DAYBACK in {15..30}; do
	DATEBACK=$(date --date "- $DAYBACK day" +%F)
	rm -rf /home/pi/backup/db/db_backup_$DATEBACK*
	rm -rf /home/pi/backup/conf/fhem_backup_$DATEBACK*
	rm -rf /home/pi/backup/log/db_backup_$DATEBACK*
done

### rsync zum NAS
if [ ! $(mount | grep -o /mnt/backup ) ]; then
  sudo mount /mnt/backup
fi
sudo $RSYNC -avht --update --no-o --no-g --no-perms /home/pi/backup/ /mnt/backup/hades/fhem  >> $LOG 2>&1
sudo umount /mnt/backup

### Backup-Zeit ausgeben
echo Backup time: `date -u -d "0 $(date +%s) seconds - $START seconds" +"%H:%M:%S"` >> $LOG 2>&1
