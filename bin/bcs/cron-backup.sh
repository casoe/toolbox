#!/bin/bash
# Autor: Carsten Söhrens

### Setting variables
SCRIPT=$0
MACHINE=$(uname -n)
DBHOST=172.16.1.103
MOUNTDIR="/mnt/backup"
BCSHOME="/opt/projektron/bcs/server"
PREFIX="bcsbackup_"
BACKUPCOPY="root@bcs-test:/opt/projektron/bcs/restore"
TODAY=$(date +%F)
YESTERDAY=$(date --date "- 1 day" +%F)
LOG="$BCSHOME/log/inform_cron/daily-backup.log"
STATISTICSLOG="$BCSHOME/log/inform_cron/daily-backup-statistics.log"
VACUUMFULLLOG="$BCSHOME/log/inform_cron/weekly-psql-vacuum-full.log"
VACUUMFULLLATEST="$BCSHOME/log/inform_cron/weekly-psql-vacuum-full-latest.log"
PGDUMP=/usr/bin/pg_dump
RSYNC=/usr/bin/rsync

# Create log directory if not existent
mkdir -p $BCSHOME/log/inform_cron

# Redirect all output -> stdout ( > ) and stderr (2>&1) into a named pipe ( >() ) running "tee"
rm -f $LOG
exec > >(tee -ia $LOG)
exec 2>&1

### Delete admin message
$BCSHOME/bin/AdminMessage.sh -d

echo "$TODAY, Daily rollover for backup started (pg_dump, rsync)" >> $STATISTICSLOG

### Stop rollover time
ROLLOVERSTART=$(date +%s)

### Check if it's the live server, otherwise abort
if [[ "$MACHINE" != 'bcs' ]]; then
  echo "This is not the live server. Abort!" && exit 1
fi

### Mount backup volume, if problem abort, BCS would continue to run
if [ ! $(mount | grep -o $MOUNTDIR ) ]; then
{
	mount -o rw $MOUNTDIR
}
fi;

if [ $? -ne 0 ]; then
{
  echo "Error: $SCRIPT could not mount $MOUNTDIR"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
  exit 1;
}
fi;

### Backup volume mount okay, let's shut down BCS
$BCSHOME/bin/ProjektronBCS.sh stop

### Start backup and stop time
BACKUPSTART=$(date +%s)

### Create necessary directories (if not already there)
mkdir -p $MOUNTDIR/$PREFIX$TODAY/db
mkdir -p $MOUNTDIR/$PREFIX$TODAY/files

### Backup the database with pg_dump (directory format with 4 jobs in parallel)
echo "### Backup the database with pg_dump (directory format with 4 jobs in parallel)"
echo "$PGDUMP -Fd -v -j 4 -h $DBHOST -U bcs --no-password -f $MOUNTDIR/$PREFIX$TODAY/db bcs"
$PGDUMP -Fd -v -j 4 -h $DBHOST -d bcs -U bcs --no-password -f $MOUNTDIR/$PREFIX$TODAY/db

### Backup the folder "files" with rsync, create hardlinks to the backup from yesterday if nothing changed
echo "### Backup the folder "files" with rsync, create hardlinks to the backup from yesterday if nothing changed"
echo "$RSYNC -avz --delete --hard-links --link-dest=$MOUNTDIR/$PREFIX$YESTERDAY/files $BCSHOME/data/files/ $MOUNTDIR/$PREFIX$TODAY/files"
$RSYNC -avz --delete --hard-links --link-dest=$MOUNTDIR/$PREFIX$YESTERDAY/files $BCSHOME/data/files/ $MOUNTDIR/$PREFIX$TODAY/files

### Sync the backup to the test-machine (for bcs-copyfromlive)
echo "### Sync the database backup and ftindex to the local machine (for bcs-copyfromlive)"
echo "$RSYNC -vPrlt --delete $MOUNTDIR/$PREFIX$TODAY/db/ $BACKUPCOPY/db"
$RSYNC -vrlt --delete $MOUNTDIR/$PREFIX$TODAY/db/ $BACKUPCOPY/db
echo "$RSYNC -vPrlt --delete $BCSHOME/data/FTIndex $BACKUPCOPY/ftindex"
$RSYNC -vrlt --delete $BCSHOME/data/FTIndex $BACKUPCOPY/ftindex
echo "$RSYNC -vPrlt --delete $BCSHOME/data/files $BACKUPCOPY/files"
$RSYNC -vrlt --delete $BCSHOME/data/files $BACKUPCOPY/files

# Backup-Größen abfragen
BACKUPSIZE=$(du -sm $MOUNTDIR/$PREFIX$TODAY |cut -f1)
FILESTORESIZE=$(du -sm $MOUNTDIR/$PREFIX$TODAY/files |cut -f1)
DBSIZE=$(du -sm $MOUNTDIR/$PREFIX$TODAY/db |cut -f1)

### Rotation: Delete backups older than 5 days
echo "### Rotation: Delete backups older than 5 days"
### For the sake of comprehensiveness try to delete everything from today -5 to today -9 days
for DAYBACK in {5..9}; do
	DATEBACK=$(date --date "- $DAYBACK day" +%F)
	echo "rm -rf $MOUNTDIR/$PREFIX$DATEBACK"
	rm -rf $MOUNTDIR/$PREFIX$DATEBACK
done

### Copy logs also to the NAS
cp $LOG $MOUNTDIR/$PREFIX$TODAY/
cp $STATISTICSLOG $MOUNTDIR/

### Unmount backup volume
umount $MOUNTDIR
if [ $? -ne 0 ]; then
{
  echo "Error: $SCRIPT could not unmount $MOUNTDIR"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
  exit 1;
}
fi;

### Hooks for special daily maintenance
sh     $BCSHOME/inform_scripts/daily-hooks
rm -rf $BCSHOME/inform_scripts/daily-hooks
touch  $BCSHOME/inform_scripts/daily-hooks

### Saturday evening and more time for vacuum full of selected tables
if [[ $(date +%u) -eq 6 ]]; then
  echo 'Saturday evening and more time for vacuum full of selected tables'
	echo $TODAY': Saturday evening and more time for vacuum full of selected tables' > $VACUUMFULLLATEST
	bash $BCSHOME/inform_scripts/cron-psql-vacuum-full.sh >> $VACUUMFULLLATEST 2>&1
	# Send log file to Carsten for checking purposes
	# cat $VACUUMFULLLATEST | mail -s "Info: Weekly maintenance cron-psql-vacuum-full.sh was executed" carsten.soehrens@inform-software.com
	cat $VACUUMFULLLATEST >> $VACUUMFULLLOG
fi

### Bring BCS back online
$BCSHOME/bin/ProjektronBCS.sh start

### Add rollover, backup time and sizes to the statistics log
echo "$TODAY, Daily rollover finished. Backup time `date -u -d "0 $BACKUPEND seconds - $BACKUPSTART seconds" +"%H:%M:%S"`. Rollover time `date -u -d "0 $(date +%s) seconds - $ROLLOVERSTART seconds" +"%H:%M:%S"`. Backup $BACKUPSIZE MB. Files $FILESTORESIZE MB. Database $DBSIZE MB." >> $STATISTICSLOG

### Send log files to Carsten for checking purposes
#cat $LOG | mail -s "Info: BCS Daily Backup Log" carsten.soehrens@inform-software.com
