#!/bin/bash
# Name : Export der Projekt-Verantwortlichen in eine csv-Datei
# Autor: Jan-Michael Regulski

SCRIPT="daily-export-project-responsibilities.sh"
BCSHOME="/opt/projektron/bcs/server"
BCSEXPORT="/opt/projektron/bcs/export"
TARGETDIR="GB30/gs3/Wiki/Quality_Support/ProjektVerantwortlichkeiten"
MOUNTDIR="/mnt/dfs"

### Mount DFS volume, if problem send mail and abort
mount -v -t cifs //intern.inform-software.com/files $MOUNTDIR -o vers=3.0,rw,credentials=/root/.cifs,noserverino

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not mount $MOUNTDIR"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;



### Start SchedulerClient for Export
echo Starte Export...
$BCSHOME/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ExportJob -t CSV_ProjectResponsibilities-INFORM-Cronjob

### Wait for 60 seconds
sleep 60s

### Copy Export file
cp -f -v $BCSEXPORT/ProjectResponsibilities.csv $MOUNTDIR/$TARGETDIR/ProjectResponsibilities.csv


### DFS wieder aushängen
umount /mnt/dfs

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not unmount $MOUNTDIR"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;


### Aufräumen des Export-Verzeichnisses
rm -rf $BCSEXPORT/ProjectResponsibilities.csv

echo ...Fertig
