##!/bin/bash
# hass-backup.sh
# Carsten Söhrens, 27.01.2025

# set -x

# Historie
# 27.01.2025 Initiale Version für Home Assistant

RSYNC="/usr/bin/rsync"
MOUNTDIR="/mnt/backup"
BACKUPDIR="/opt/homeAssistant/data/backups"

### Startzeit speichern
echo "INFO Start von $0"
START=$(date +%s)

### NAS mounten; bei Fehler Abbruch und Mail versenden
echo "INFO NAS mounten; bei Fehler Abbruch und Nachricht versenden"
if [ ! $(mount | grep -o $MOUNTDIR ) ]; then
  echo "sudo mount $MOUNTDIR"
  sudo mount $MOUNTDIR

	if [ $? -ne 0 ]; then
	{
                curl -X POST -H "Content-Type: application/json" 'http://localhost:8080/v2/send' -d '{"message": ""ERROR during NAS mount for daily backup!", "number": "+491743137628", "recipients": [ "+4915152657436" ]}'
		exit 1;
	}
	fi;
fi

### rsync der lokalen Backup-Daten zum NAS
echo "INFO rsync der lokalen Backup-Daten zum NAS"
echo "sudo $RSYNC -avht --update --no-o --no-g --no-perms $BACKUPDIR/ $MOUNTDIR/hass"
sudo $RSYNC -avht --update --no-o --no-g --no-perms $BACKUPDIR/ $MOUNTDIR/hass

### Löschen alter Backupdateien älter als 4 Wochen
echo "INFO Löschen Logfiles älter als 4 Wochen"
find $BACKUPDIR/* -mtime +28
sudo find $BACKUPDIR/* -mtime +28 -delete


echo "sudo umount $MOUNTDIR"
sudo umount $MOUNTDIR

### Backup-Zeit ausgeben
echo "INFO Backup time $(date -u -d "0 $(date +%s) seconds - $START seconds" +"%H:%M:%S")"
