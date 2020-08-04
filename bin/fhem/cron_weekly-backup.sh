#!/bin/bash
# hades-backup.sh
# Carsten Söhrens, 20.02.2020

 set -x

# Historie
# 20.02.2020 Erste konsolidierte Version, soll einmal die Woche laufen (Backupzeit bei Test im Bereich von 8 min)
# 22.02.2020 Verschiedene Fixes und Optimierungen nach dem ersten Lauf über crontab
# 03.05.2020 Umstellung Logging und Versand des Logfiles per Mail am Ende hinzugefügt
# 23.05.2020 Fix in Bezug auf mount mit sudo
# 31.05.2020 Logging angepasst auf die gleiche Funktion wie im daily-backup
# 08.06.2020 Umstellung beim Mounten; bei Fehler wird eine Mail versandt und das Skript abgebrochen

RASPIBACKUP="/usr/local/bin/raspiBackup.sh"
MOUNTDIR="/mnt/backup"
TODAY=$(date +"%Y-%m-%d")
LOG="/home/pi/backup/log/weekly_backup_$TODAY.log"

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

### Postgres-DB stoppen und Backup des Gesamtsystems durchführen
log "INFO" "Postgres stoppen"
sudo systemctl stop postgresql >> $LOG 2>&1
sudo systemctl status postgresql >> $LOG 2>&1
log "INFO" "Backup des Gesamtsystems durch raspiBackup durchführen"
sudo $RASPIBACKUP -a : -o : -m minimal >> $LOG 2>&1

### Restart Postgres und Backup-Mount aushängen
log "INFO" "Postgres starten"
sudo systemctl start postgresql >> $LOG 2>&1
sudo systemctl status postgresql >> $LOG 2>&1

### Größen der bisherigen Backups anzeigen
log "INFO" "Größen der bisherigen Backups anzeigen"
sudo du -sm /mnt/backup/hades/* >> $LOG 2>&1

### NAS unmounten
log "INFO" "NAS unmounten"
sudo umount $MOUNTDIR >> $LOG 2>&1

### Backup-Zeit ausgeben
log "INFO" "Backup-Zeit ausgeben"
echo Backup time $(date -u -d "0 $(date +%s) seconds - $START seconds" +"%H:%M:%S") >> $LOG 2>&1

### Log per Mail versenden
log "INFO" "Log per Mail versenden"
cat $LOG | mail -s "Hades (FHEM) Weekly Backup" soehrens@gmail.com
