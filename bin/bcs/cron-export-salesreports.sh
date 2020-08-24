#!/bin/bash
# Name : cron-export-salesreports.sh
# Autor: Carsten Söhrens

### Setze Variablen
SCRIPT="cron-export-salesreports.sh"
MOUNTDIR="/mnt/dfs"
BCSHOME="/opt/projektron/bcs/server"
BCSEXPORT="/opt/projektron/bcs/export"
SCHEDULERDEF="FILE_Salesreport_Documents"

### Mount DFS volume, if problem send mail and abort
if [ ! $(mount | grep -o $MOUNTDIR ) ]; then
{
	mount -v -t cifs //intern.inform-software.com/files $MOUNTDIR -o vers=3.0,rw,credentials=/root/.cifs,noserverino
}
fi;

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not mount $MOUNTDIR"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

### Start SchedulerClient for Export
echo Starte Export...
$BCSHOME/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ExportJob -t $SCHEDULERDEF

### Wait for 60 seconds to make sure the export is complete (usually files are instantly there)
echo Wait for 60 seconds
sleep 60s

cd /opt/projektron/bcs/export/

### Rename files and set file timestamps to creation date from filename
for file in $(ls *GB30*.xlsx)
do
	day=${file:0:2}
	month=${file:3:2}
	year=${file:6:4}
	hour=${file:11:2}
	min=${file:14:2}
	sec=${file:17:2}
	extension=${file: -4}

	touch -t $year$month$day$hour$min $file
	mv -f $file GB30-Sales-Report_$year\-$month\-$day.$extension

done

for file in $(ls *GB70*.xlsx)
do
	day=${file:0:2}
	month=${file:3:2}
	year=${file:6:4}
	hour=${file:11:2}
	min=${file:14:2}
	sec=${file:17:2}
	extension=${file: -4}

	touch -t $year$month$day$hour$min $file
	mv -f $file GB70-Sales-Report_$year\-$month\-$day.$extension

done

### Synchronisiere Sales-Reports auf das DFS und lösche lokale Dateien
### Mit rsync bleiben die über touch gesetzten timestamps erhalten
mkdir -p /mnt/dfs/Global/GB30/Orderbook
rsync -avP GB30*.xlsx /mnt/dfs/Global/GB30/Orderbook/
rm -f GB30*.xlsx

mkdir -p /mnt/dfs/Global/GB70/Orderbook
rsync -avP GB70*.xlsx /mnt/dfs/Global/GB70/Orderbook
rm -f GB70*.xlsx

### DFS wieder aushängen
umount /mnt/dfs

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not unmount $MOUNTDIR"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;
