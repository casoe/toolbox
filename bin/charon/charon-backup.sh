##!/bin/bash
# charon-backup.sh
# Carsten Söhrens, 08.08.2022

# set -x

# Historie
# 08.08.2022 Initiale Version
# 16.08.2022 Bugfixes und Verbesserungen
# 15.01.2023 Bugfix an find --delete und Erweiterung um DokuWiki-Seiten
# 02.02.2023 Kompletten data-Ordner von DokuWiki sichern

### Variablen
HOME="/home/carsten"
RSYNC="/usr/bin/rsync"
MOUNTDIR="/mnt/backup"
BACKUPDIR="/home/carsten/docker/data/pihole/etc-pihole/backup"

### Startzeit speichern
echo "INFO Start von $0"
START=$(date +%s)

### Backup der Pi-Hole Daten über den Container in ein gemapptes Volume
docker exec pihole pihole -a teleporter /etc/pihole/backup/pihole-charon-teleporter_$(date -I).tar

### Backup der DokuWiki-Seiten
tar cvzf $BACKUPDIR/dokuwiki-backup_$(date -I).tgz /home/carsten/docker/data/dokuwiki/dokuwiki/data

### Löschen alter Backupdateien älter als 4 Wochen
echo "INFO Löschen Logfiles älter als 4 Wochen"
find $BACKUPDIR/* -mtime +28
sudo find $BACKUPDIR/* -mtime +28 -delete

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
