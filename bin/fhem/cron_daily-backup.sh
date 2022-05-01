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
# 01.05.2022 Umstellung der Backup-Pfade auf das Docker-Setup, HOME in Variable gesetzt

HOME="/home/pi"
PGDUMP="/usr/bin/pg_dump"
PSQL="/usr/bin/psql"
ZIP="/usr/bin/zip"
DBNAME="postgresql://fhem:fhem@localhost:5432/fhem"
TODAY=`date +"%Y-%m-%d"`
LOG="$HOME/backup/log/db_backup_$TODAY.log"
DBTARGET="$HOME/backup/db/db_backup_$TODAY.sqlc"
ZIPTARGET="$HOME/backup/conf/fhem_backup_$TODAY.zip"
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

### Abfrage der Anzahl der Einträge in der Datenbank
log "INFO" "Abfrage der Anzahl der Einträge in der Datenbank"
$PSQL $DBNAME << EOF >> $LOG 2>&1
select type, reading, count(*) from history group by type,reading order by type,reading;
select count(*) from history;
EOF

### Dump der Postgres-Datenbank
log "INFO" "Dump der Postgres-Datenbank mit: $PGDUMP -v -Fc --file=$DBTARGET $DBNAME"
$PGDUMP -v -Fc --file=$DBTARGET $DBNAME >> $LOG 2>&1

### Wiederherstellen-Hinweis im Logfile
log "INFO" "Wiederherstellen mit: pg_restore -Fc -v --clean -h localhost -U fhem -d fhem $DBTARGET"

### Archivieren des Skripts und der Config-Dateien
log "INFO" "Archivieren der wichtigsten Config-Dateien"
$ZIP -rv $ZIPTARGET $HOME/fhem-docker/fhem/fhem.cfg >> $LOG 2>&1
$ZIP -rv $ZIPTARGET $HOME/fhem-docker/fhem/db.conf >> $LOG 2>&1
$ZIP -rv $ZIPTARGET $HOME/fhem-docker/fhem/www/gplot/myPlot*.gplot >> $LOG 2>&1
$ZIP -rv $ZIPTARGET $HOME/.bash_history >> $LOG 2>&1

### Löschen aller lokalen Dateien von Tag -15 bis -30
log "INFO" "Löschen aller lokalen Dateien von Tag -15 bis -30 sowie alter Log-Dateien"
for DAYBACK in {15..30}; do
	DATEBACK=$(date --date "- $DAYBACK day" +%F)
	rm -rf $HOME/backup/db/db_backup_$DATEBACK*
	rm -rf $HOME/backup/conf/fhem_backup_$DATEBACK*
	rm -rf $HOME/backup/log/db_backup_$DATEBACK*
	rm -rf $HOME/fhem-docker/fhem/log/fhem-$DATEBACK*
done

rm $HOME/backup/log/weekly_backup_$(date --date "-3 month" +%+4Y-%m-)*


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
sudo $RSYNC -avht --update --no-o --no-g --no-perms $HOME/backup/ $MOUNTDIR/hades/fhem  >> $LOG 2>&1

sudo umount $MOUNTDIR

### Backup-Zeit ausgeben
log "INFO" "Backup time $(date -u -d "0 $(date +%s) seconds - $START seconds" +"%H:%M:%S")"
