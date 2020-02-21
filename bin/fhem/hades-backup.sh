#!/bin/bash
# hades-backup.sh
# Carsten Söhrens, 20.02.2020

# set -x

# Historie
# 20.02.2020 Erste konsolidierte Version, soll einmal die Woche laufen (Backupzeit bei Test im Bereich von 8 min)

RASPIBACKUP=/usr/local/bin/raspiBackup.sh
LOG="/home/pi/weekly_backup_$TODAY.log"

# Startzeit speichern
START=$(date +%s)

### NAS mounten
if [ ! $(mount | grep -o /mnt/backup ) ]; then
  mount /mnt/backup
fi

# Postgres-DB stoppen und Backup des Gesamtsystems durchführen
sudo systemctl stop postgresql
sudo systemctl status postgresql > $LOG 2>&1
sudo $RASPIBACKUP -a : -o : -m detailed >> $LOG 2>&1

# Restart Postgres und Backup-Mount aushängen
sudo systemctl start postgresql
sudo systemctl status postgresql >> $LOG 2>&1

### NAS unmounten
umount /mnt/backup

### Backup-Zeit ausgeben
echo Backup time: `date -u -d "0 $(date +%s) seconds - $START seconds" +"%H:%M:%S"` >> $LOG 2>&1
