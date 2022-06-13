#!/bin/bash
# hades-backup.sh
# Carsten Söhrens, 20.02.2020

# set -x

# Historie
# 20.02.2020 Erste konsolidierte Version, soll einmal die Woche laufen (Backupzeit bei Test im Bereich von 8 min)
# 22.02.2020 Verschiedene Fixes und Optimierungen nach dem ersten Lauf über crontab
# 03.05.2020 Umstellung Logging und Versand des Logfiles per Mail am Ende hinzugefügt
# 23.05.2020 Fix in Bezug auf mount mit sudo
# 31.05.2020 Logging angepasst auf die gleiche Funktion wie im daily-backup
# 08.06.2020 Umstellung beim Mounten; bei Fehler wird eine Mail versandt und das Skript abgebrochen
# 22.05.2022 Nach Umstellung auf Container das Stoppen und Starten der Postgres-DB entfernt
# 23.05.2022 Diverse Pfade korrigiert
# 28.05.2022 Logging noch mal angepasst (Funktion wieder entfernt)

HOME="/home/carsten"
RASPIBACKUP="/usr/local/bin/raspiBackup.sh"
MOUNTDIR="/mnt/backup"
TODAY=$(date +"%Y-%m-%d")
LOG="$HOME/backup/log/weekly_backup_$TODAY.log"

### speichern
echo "INFO Start von $0"
START=$(date +%s)

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

### Backup des Gesamtsystems durchführen
echo "INFO Backup des Gesamtsystems durch raspiBackup durchführen"
sudo $RASPIBACKUP -a : -o : -m minimal

### NAS unmounten
echo "INFO NAS unmounten"
sudo umount $MOUNTDIR

### Backup-Zeit ausgeben
echo "INFO Backup-Zeit ausgeben"
echo Backup time $(date -u -d "0 $(date +%s) seconds - $START seconds" +"%H:%M:%S")

### Löschen alter Logfiles älter als 10 Wochen
echo "INFO Löschen Logfiles älter als 10 Wochen"
find $HOME/backup/log/weekly_backup_* -mindepth 1 -mtime +70
find $HOME/backup/log/weekly_backup_* -mindepth 1 -mtime +70 -delete

### Logile und Mailbox in Home löschen
rm -rf $HOME/raspiBackup.*

### Log per Mail versenden
#echo "INFO Log per Mail versenden"
#cat $LOG | mail -s "Hades (FHEM) Weekly Backup" soehrens@gmail.com
