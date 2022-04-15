#!/bin/bash
# fhem-sqltest.sh
# Carsten Söhrens, 16.09.2017

# set -x

PGDUMP="/usr/bin/pg_dump"
PSQL="/usr/bin/psql"
ZIP="/usr/bin/zip"
DBNAME="postgresql://fhem:fhem@localhost:5432/fhem"
TODAY=`date +"%Y-%m-%d"`
LOG="/home/pi/log/db_backup_$TODAY.log"
DBTARGET="/home/pi/backup/db_backup_$TODAY.sqlc"
ZIPTARGET="/home/pi/backup/fhem_backup_$TODAY.zip"
REMOTE="/mnt/hd2tb/photos"

#$PSQL $DBNAME << EOF >> fhem-sqltest.log 2>&1
$PSQL $DBNAME << EOF
select type, reading, count(*) from history group by type,reading order by type,reading;
select count (*) from history;
EOF
