#!/bin/bash
# hades-backup.sh
# Carsten Söhrens, 20.02.2020

# set -x

# Historie
# 20.02.2020 Erste konsolidierte Version, soll einmal die Woche laufen (Backupzeit bei Test im Bereich von 8 min)
# 22.02.2020 Verschiedene Fixes und Optimierungen nach dem ersten Lauf über crontab

RASPIBACKUP=/usr/local/bin/raspiBackup.sh
TODAY=`date +"%Y-%m-%d"`
LOG="/home/pi/backup/log/weekly_backup_$TODAY.log"

# Startzeit speichern
START=$(date +%s)

### NAS mounten
if [ ! $(mount | grep -o /mnt/backup ) ]; then
  mount /mnt/backup
fi

# Postgres-DB stoppen und Backup des Gesamtsystems durchführen
sudo systemctl stop postgresql
sudo systemctl status postgresql > $LOG 2>&1
sudo $RASPIBACKUP -a : -o : -m minimal >> $LOG 2>&1

# Restart Postgres und Backup-Mount aushängen
sudo systemctl start postgresql
sudo systemctl status postgresql >> $LOG 2>&1

### NAS unmounten
umount /mnt/backup

### Backup-Zeit ausgeben
echo Backup time: `date -u -d "0 $(date +%s) seconds - $START seconds" +"%H:%M:%S"` >> $LOG 2>&1
