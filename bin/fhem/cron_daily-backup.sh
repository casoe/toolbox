##!/bin/bash
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
# 23.05.2022 Löschen des Logs beim Weekly-Backup entfernt
# 28.05.2022 Logging noch mal angepasst (Funktion wieder entfernt)
# 28.10.2024 Restore 1x die Woche hinzugefügt, um Bloat in der DB loszuwerden

HOME="/home/carsten"
PGDUMP="/usr/bin/pg_dump"
PSQL="/usr/bin/psql"
ZIP="/usr/bin/zip"
DBNAME="postgresql://fhem:fhem@localhost:5432/fhem"
TODAY=$(date +"%Y-%m-%d")
LOG="$HOME/backup/log/db_backup_$TODAY.log"
DBTARGET="$HOME/backup/db/db_backup_$TODAY.sqlc"
ZIPTARGET="$HOME/backup/conf/fhem_backup_$TODAY.zip"
RSYNC="/usr/bin/rsync"
MOUNTDIR="/mnt/backup"

### Startzeit speichern
echo "INFO Start von $0"
START=$(date +%s)

### Abfrage der Anzahl der Einträge in der Datenbank
echo "INFO Abfrage der Anzahl der Einträge in der Datenbank"
$PSQL $DBNAME << EOF
select type, reading, count(*) from history group by type,reading order by type,reading;
select count(*) from history;
EOF

### Dump der Postgres-Datenbank
echo "INFO Dump der Postgres-Datenbank mit: $PGDUMP -v -Fc --file=$DBTARGET $DBNAME"
$PGDUMP -v -Fc --file=$DBTARGET $DBNAME

### Wiederherstellen-Hinweis im Logfile
echo "INFO Wiederherstellen mit: pg_restore -Fc -v --clean -h localhost -U fhem -d fhem $DBTARGET"

### Samstagabend und Zeit für einen Restore, um Bloat loszuwerden
if [[ $(date +%u) -eq 6 ]]; then

  # Datenbank-Logging in FHEM pausieren
  echo "set dblog reopen 7200" | /bin/nc -w5 localhost 7072
  # Restore
  pg_restore -Fc -v --clean -h localhost -U fhem -d fhem $DBTARGET
  # Datenbank-Logging in FHEM fortsetzen
  echo "set dblog reopen" | /bin/nc -w5 localhost 7072

fi

### Archivieren des Skripts und der Config-Dateien
echo "INFO Archivieren der wichtigsten Config-Dateien"
$ZIP -rv $ZIPTARGET $HOME/fhem-docker/fhem/fhem.cfg
$ZIP -rv $ZIPTARGET $HOME/fhem-docker/fhem/db.conf
$ZIP -rv $ZIPTARGET $HOME/fhem-docker/fhem/www/gplot/myPlot*.gplot
$ZIP -rv $ZIPTARGET $HOME/.bash_history

### Löschen aller lokalen Dateien von Tag -15 bis -30
echo "INFO Löschen aller lokalen Dateien von Tag -15 bis -30 sowie alter Log-Dateien"
for DAYBACK in {15..30}; do
	DATEBACK=$(date --date "- $DAYBACK day" +%F)
	rm -rf $HOME/backup/db/db_backup_$DATEBACK*
	rm -rf $HOME/backup/conf/fhem_backup_$DATEBACK*
	rm -rf $HOME/backup/log/db_backup_$DATEBACK*
	rm -rf $HOME/fhem-docker/fhem/log/fhem-$DATEBACK*
done

### NAS mounten; bei Fehler Abbruch und Mail versenden
echo "INFO NAS mounten; bei Fehler Abbruch und Mail versenden"
if [ ! $(mount | grep -o $MOUNTDIR ) ]; then
  echo "sudo mount $MOUNTDIR"
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
echo "sudo $RSYNC -avht --update --no-o --no-g --no-perms $HOME/backup/ $MOUNTDIR/hades.daily"
sudo $RSYNC -avht --update --no-o --no-g --no-perms $HOME/backup/ $MOUNTDIR/hades.daily

echo "sudo umount $MOUNTDIR"
sudo umount $MOUNTDIR

### Backup-Zeit ausgeben
echo "INFO Backup time $(date -u -d "0 $(date +%s) seconds - $START seconds" +"%H:%M:%S")"
