#!/bin/bash
# Name : daily-backup.sh
# Autor: Carsten Söhrens

### Setting variables
SCRIPT="daily-backup.sh"
MACHINE=$(uname -n)
DBHOST=172.16.1.103
MOUNTDIR="/mnt/backup"
BCSHOME="/opt/projektron/bcs/server"
PREFIX="bcsbackup_"
BACKUPCOPY="/opt/projektron/bcs/backup"
TODAY=$(date +%F)
YESTERDAY=$(date --date "- 1 day" +%F)
LOG="$BCSHOME/log/daily-backup.log"
STATISTICSLOG="$BCSHOME/log/daily-backup-statistics.log"
PGDUMP=/usr/bin/pg_dump
RSYNC=/usr/bin/rsync

# Redirect all output -> stdout ( > ) and stderr (2>&1) into a named pipe ( >() ) running "tee"
rm -f $LOG
exec > >(tee -ia $LOG)
exec 2>&1

echo "$TODAY, Daily rollover for new backup started - experimental, db-backup with pg_dump, files with rsync" >> $STATISTICSLOG

### Stop rollover time
ROLLOVERSTART=$(date +%s)

### Check if it's the live server, otherwise abort
if [[ "$MACHINE" != 'bcs' ]]; then
  echo "This is not the live server. Abort!" && exit 1
fi

### Mount backup volume, if problem abort
mount -o rw $MOUNTDIR
if [ $? -ne 0 ]; then
{
  echo "Error: $SCRIPT could not mount $MOUNTDIR"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
  exit 1;
}
fi;

### Shutdown BCS
$BCSHOME/bin/ProjektronBCS.sh stop

### Start backup and stop time
BACKUPSTART=$(date +%s)

### Create necessary directories
mkdir -p $MOUNTDIR/$PREFIX$TODAY/db
mkdir -p $MOUNTDIR/$PREFIX$TODAY/files
mkdir -p $BACKUPCOPY/current/db
mkdir -p $BACKUPCOPY/current/files

### Backup the database with pg_dump (directory format with 4 jobs in parallel)
echo "### Backup the database with pg_dump (directory format with 4 jobs in parallel)"
echo "$PGDUMP -Fd -v -j 4 -h $DBHOST -U bcs --no-password -f $MOUNTDIR/$PREFIX$TODAY/db bcs"
$PGDUMP -Fd -v -j 4 -h $DBHOST -U bcs --no-password -f $MOUNTDIR/$PREFIX$TODAY/db bcs

### Backup the folder "files" with rsync, create hardlinks to the backup from yesterday if nothing changed
echo "### Backup the folder "files" with rsync, create hardlinks to the backup from yesterday if nothing changed"
echo "$RSYNC -avz --delete --hard-links --link-dest=$MOUNTDIR/$PREFIX$YESTERDAY/files $BCSHOME/data/files/ $MOUNTDIR/$PREFIX$TODAY/files"
$RSYNC -avz --delete --hard-links --link-dest=$MOUNTDIR/$PREFIX$YESTERDAY/files $BCSHOME/data/files/ $MOUNTDIR/$PREFIX$TODAY/files

### Sync the database backup to the local machine (for bcs-copyfromlive)
echo "### Sync the database backup to the local machine (for bcs-copyfromlive)"
echo "$RSYNC -avz --delete $MOUNTDIR/$PREFIX$TODAY/db/ $BACKUPCOPY/current/db"
$RSYNC -avz --delete $MOUNTDIR/$PREFIX$TODAY/db/ $BACKUPCOPY/current/db

### Create a snapshot of the files-directory for a consistent backup locally
echo "### Create a snapshot of the files-directory for a consistent backup locally"
echo "$RSYNC -avz --delete --hard-links --link-dest=$BCSHOME/data/files $BCSHOME/data/files/ $BACKUPCOPY/current/files"
$RSYNC -avz --delete --hard-links --link-dest=$BCSHOME/data/files $BCSHOME/data/files/ $BACKUPCOPY/current/files

BACKUPSIZE=$(du -sm $MOUNTDIR/$PREFIX$TODAY |cut -f1)
FILESTORESIZE=$(du -sm $BCSHOME/data/files |cut -f1)
DBSIZE=$(du -sm $BACKUPCOPY/current/db |cut -f1)

### Rotation: Delete backups older than 5 days
echo "### Rotation: Delete backups older than 5 days"
### For the sake of comprehensiveness try to delete everything from today -6 to today -10 days
for DAYBACK in {6..10}; do
	DATEBACK=$(date --date "- $DAYBACK day" +%F)
	echo "rm -rf $MOUNTDIR/$PREFIX$DATEBACK"
	rm -rf $MOUNTDIR/$PREFIX$DATEBACK
done

### Copy log also to the NAS
cp $LOG $MOUNTDIR/$PREFIX$TODAY/

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

### Bring BCS online again
$BCSHOME/bin/ProjektronBCS.sh start

### Add rollover, backup time and sizes to the statistics log
echo "$TODAY, Daily rollover finished. Backup time `date -u -d "0 $BACKUPEND seconds - $BACKUPSTART seconds" +"%H:%M:%S"`. Rollover time `date -u -d "0 $(date +%s) seconds - $ROLLOVERSTART seconds" +"%H:%M:%S"`. Backup $BACKUPSIZE MB. Files $FILESTORESIZE MB. Database $DBSIZE MB." >> $STATISTICSLOG
