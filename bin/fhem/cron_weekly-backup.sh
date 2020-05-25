#!/bin/bash
# hades-backup.sh
# Carsten Söhrens, 20.02.2020

# set -x

# Historie
# 20.02.2020 Erste konsolidierte Version, soll einmal die Woche laufen (Backupzeit bei Test im Bereich von 8 min)
# 22.02.2020 Verschiedene Fixes und Optimierungen nach dem ersten Lauf über crontab
# 03.05.2020 Umstellung Logging und Versand des Logfiles per Mail am Ende hinzugefügt
# 23.05.2020 Fix in Bezug auf mount mit sudo

RASPIBACKUP=/usr/local/bin/raspiBackup.sh
TODAY=`date +"%Y-%m-%d"`
LOG="/home/pi/backup/log/weekly_backup_$TODAY.log"

### Funktion zum effizienteren Logging
function log {
    echo "[$(date --rfc-3339=seconds)]: $*"
}

### Logging initialisieren
rm -f $LOG
exec > >(tee -ia $LOG)
exec 2>&1

### Startzeit speichern
START=$(date +%s)

### NAS mounten
log NAS mounten
if [ ! $(mount | grep -o /mnt/backup ) ]; then
  sudo mount /mnt/backup
fi

### Postgres-DB stoppen und Backup des Gesamtsystems durchführen
log Postgres-DB stoppen und Backup des Gesamtsystems durchführen
sudo systemctl stop postgresql >> $LOG 2>&1
sudo systemctl status postgresql >> $LOG 2>&1
sudo $RASPIBACKUP -a : -o : -m minimal >> $LOG 2>&1

### Restart Postgres und Backup-Mount aushängen
log Restart Postgres und Backup-Mount aushängen
sudo systemctl start postgresql >> $LOG 2>&1
sudo systemctl status postgresql >> $LOG 2>&1

### Größen der bisherigen Backups anzeigen
log Größen der bisherigen Backups anzeigen
sudo du -sm /mnt/backup/hades/hades-rsync-backup-* >> $LOG 2>&1

### NAS unmounten
sudo umount /mnt/backup >> $LOG 2>&1

### Backup-Zeit ausgeben
echo Backup time: `date -u -d "0 $(date +%s) seconds - $START seconds" +"%H:%M:%S"` >> $LOG 2>&1

### Log per Mail versenden
cat $LOG | mail -s "Hades (FHEM) Weekly Backup" soehrens@gmail.com
