#!/bin/bash
# Zweck: Export der Projekt-Verantwortlichen in eine csv-Datei
# Autor: Jan-Michael Regulski

SCRIPT="daily-export-project-responsibilities.sh"
BCSHOME="/opt/projektron/bcs/server"
BCSEXPORT="/opt/projektron/bcs/export"
TARGETDIR="GB30/gs3/Wiki/Quality_Support/ProjektVerantwortlichkeiten"
MOUNTDIR="/mnt/dfs"

mountcheck="false"

### Mount DFS volume (if not alredy available), if problem send mail and abort
if ! [[ $(findmnt -M "$MOUNTDIR") ]]; then
    echo "Mounten von //INFORM/files..."
    mount -v -t cifs //intern.inform-software.com/files $MOUNTDIR -o vers=3.0,rw,credentials=/root/.cifs,noserverino
    mountcheck="true"
fi
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


if [ "$mountcheck" == "true" ] ; then
  ### DFS wieder aushängen, wenn in Script eingehängt
  umount /mnt/dfs
fi

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not unmount $MOUNTDIR"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;


### Aufräumen des Export-Verzeichnisses
rm -rf $BCSEXPORT/ProjectResponsibilities.csv

echo ...Fertig
