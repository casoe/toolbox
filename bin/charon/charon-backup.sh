##!/bin/bash
# charon-backup.sh
# Carsten Söhrens, 08.08.2022

# set -x

# Historie
# 08.08.2022 Initiale Version

HOME="/home/carsten"
RSYNC="/usr/bin/rsync"
MOUNTDIR="/mnt/backup"
BACKUPDIR="/home/carsten/docker/data/pihole/etc-pihole/backup"

### Startzeit speichern
echo "INFO Start von $0"
START=$(date +%s)

### Löschen alter Backupdateien älter als 4 Wochen
echo "INFO Löschen Logfiles älter als 4 Wochen"
find $BACKUPDIR/* -mindepth 1 -mtime +28
find $BACKUPDIR/* -mindepth 1 -mtime +28 -delete

### NAS mounten; bei Fehler Abbruch und Mail versenden
echo "INFO NAS mounten; bei Fehler Abbruch und Mail versenden"
if [ ! $(mount | grep -o $MOUNTDIR ) ]; then
  sudo mount $MOUNTDIR

	if [ $? -ne 0 ]; then
	{
		cat $LOG |mail -s "ERROR $0" soehrens@gmail.com
		exit 1;
	}
	fi;
fi

### rsync der lokalen Backup-Daten zum NAS
echo "INFO rsync der lokalen Backup-Daten zum NAS"
sudo $RSYNC -avht --update --no-o --no-g --no-perms $BACKUPDIR/ $MOUNTDIR/charon

sudo umount $MOUNTDIR

### Backup-Zeit ausgeben
echo "INFO Backup time $(date -u -d "0 $(date +%s) seconds - $START seconds" +"%H:%M:%S")"
