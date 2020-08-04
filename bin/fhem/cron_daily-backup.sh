#!/bin/bash
# cron_daily-backup.sh
# Carsten Söhrens, 25.05.2017

# set -x

# Historie
# 06.01.2020 Umstellung auf neue Ordnerstruktur und Sync mit dem NAS statt mit OSMC
# 07.01.2020 Stoppen der Zeit ergänzt
# 23.05.2020 Fix in Bezug auf mount mit sudo
# 25.05.2020 Fix an Permissions-Error für rsync; delete backups older than 14 days locally
# 26.05.2020 Logging angepasst
# 28.05.2020 Bugfix am Logging (> statt >>)
# 08.06.2020 Umstellung beim Mounten; bei Fehler wird eine Mail versandt und das Skript abgebrochen

PGDUMP="/usr/bin/pg_dump"
PSQL="/usr/bin/psql"
ZIP="/usr/bin/zip"
DBNAME="postgresql://fhem:fhem@localhost:5432/fhem"
TODAY=`date +"%Y-%m-%d"`
LOG="/home/pi/backup/log/db_backup_$TODAY.log"
DBTARGET="/home/pi/backup/db/db_backup_$TODAY.sqlc"
ZIPTARGET="/home/pi/backup/conf/fhem_backup_$TODAY.zip"
RSYNC="/usr/bin/rsync"
MOUNTDIR="/mnt/backup"

### Funktion zum effizienteren Logging
log() {
	if [[ -z "$LOG" ]]; then
			echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: ERROR log variable in $0 not defined" 1>&2
			exit 1
	fi

	echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: $*" >> $LOG 2>&1
}

### Log öffnen und Startzeit speichern
log "INFO" "Start von $0"
START=$(date +%s)

### Löschen von Einträgen für Power, die älter als 7 Tage sind
log "INFO" "Löschen von Einträgen für Power, die älter als 7 Tage sind"
$PSQL $DBNAME << EOF >> $LOG 2>&1
delete from history where reading='ENERGY_Power' and (timestamp < now() - interval '7 days');
delete from history where reading='power' and (timestamp < now() - interval '7 days');
delete from history where type='SYSSTAT' and (timestamp < now() - interval '30 days');
select type, reading, count(*) from history group by type,reading order by type,reading;
select count(*) from history;
EOF

### Dump der Postgres-Datenbank
log "INFO" "Dump der Postgres-Datenbank"
$PGDUMP -v -Fc --file=$DBTARGET $DBNAME >> $LOG 2>&1

### Wiederherstellen-Hinweis im Logfile
log "INFO" "Wiederherstellen mit pg_restore -Fc -v --clean -h localhost -U fhem -d fhem $DBTARGET"

### Archivieren des Skripts und der Config-Dateien
log "INFO" "Archivieren der relevanten Config-Dateien"
$ZIP -rv $ZIPTARGET /opt/fhem/fhem.cfg >> $LOG 2>&1
$ZIP -rv $ZIPTARGET /opt/fhem/db.conf >> $LOG 2>&1
$ZIP -rv $ZIPTARGET /home/pi/.bash_history >> $LOG 2>&1
$ZIP -rv $ZIPTARGET /opt/fhem/www/gplot/myPlot*.gplot >> $LOG 2>&1
$ZIP -rv $ZIPTARGET /opt/fhem/www/tablet/index.html >> $LOG 2>&1

### Löschen aller lokalen Dateien von Tag -15 bis -30
log "INFO" "Löschen aller lokalen Dateien von Tag -15 bis -30"
for DAYBACK in {15..30}; do
	DATEBACK=$(date --date "- $DAYBACK day" +%F)
	rm -rf /home/pi/backup/db/db_backup_$DATEBACK*
	rm -rf /home/pi/backup/conf/fhem_backup_$DATEBACK*
	rm -rf /home/pi/backup/log/db_backup_$DATEBACK*
done

### NAS mounten; bei Fehler Abbruch und Mail versenden
log "INFO" "NAS mounten; bei Fehler Abbruch und Mail versenden"
if [ ! $(mount | grep -o $MOUNTDIR ) ]; then
  sudo mount $MOUNTDIR >> $LOG 2>&1
	
	if [ $? -ne 0 ]; then
	{
		cat $LOG |mail -s "ERROR $0" soehrens@gmail.com
		exit 1;
	}
	fi;
fi

### rsync der lokalen Backup-Daten zum NAS
log "INFO" "rsync der lokalen Backup-Daten zum NAS"
sudo $RSYNC -avht --update --no-o --no-g --no-perms /home/pi/backup/ $MOUNTDIR/hades/fhem  >> $LOG 2>&1

sudo umount $MOUNTDIR

### Backup-Zeit ausgeben
log "INFO" "Backup time $(date -u -d "0 $(date +%s) seconds - $START seconds" +"%H:%M:%S")"
