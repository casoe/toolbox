#!/bin/bash
# Name : cron-export-project-responsibilities.sh
# Autor: Jan-Michael Regulski
# Einsatz: Import der manuell geänderten Projekt-Verantwortlichkeits-Relationen

SUPPORTMAIL="bcs-support@inform-software.com"

SCRIPT="cron-export-project-responsibilities.sh"
BCSHOME="/opt/projektron/bcs/server"
BCSIMPORT="/opt/projektron/bcs/import"
SOURCEDIR="GB30/gs3/Wiki/Quality_Support/ProjektVerantwortlichkeiten/import"
SCRIPDIR="inform_scripts"
MOUNTDIR="/mnt/dfs"

exortfileprefix="ProjectResponsibilities"
FULLDATE=$(date +"%Y-%-m-%-d")
FULLTIME=$(date +"%H-%M")

mountcheck="false"
###Umlenken aller Ausgaben/Fehler in eine Datei
exec > $BCSIMPORT/$exortfileprefix$FULLDATE-$FULLTIME.log
exec 2>&1

### Mount DFS volume (if not alredy available), if problem send mail and abort
if ! [[ $(findmnt -M "$MOUNTDIR") ]]; then
    echo "Mounten von //INFORM/files..."
    mount -v -t cifs //intern.inform-software.com/files $MOUNTDIR -o vers=3.0,rw,credentials=/root/.cifs,noserverino
    mountcheck="true"
fi
if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not mount $MOUNTDIR"|mail -s "BCS $SCRIPT" $SUPPORTMAIL
	exit 1;
}
fi;


###Test, ob eine AllePosten-Datei vorhanden ist
if [ -f $MOUNTDIR/$SOURCEDIR/$exortfileprefix.db ] ; then


  ###Kopieren der DB
  echo "Kopieren der Quelldatei auf den BCS-Server..."
  cp -f -v -a $MOUNTDIR/$SOURCEDIR/$exortfileprefix.db $BCSIMPORT

  ### Import anstoßen
  echo "Starte Import..."
  $BCSHOME/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ImportJob -t JDBC_Import_ProjectResponsibilities-INFORM-Cronjob

  ### Wait for 60 seconds
  sleep 30s

  ###Löschen der Importdateien
  # rm -rf $MOUNTDIR/$SOURCEDIR/$exortfileprefix.db
  rm -rf $BCSIMPORT/$exortfileprefix.db

else
    echo "Keine ProjectResponsibilities-Datenbank zum Kopieren vorhanden"
fi

if [ "$mountcheck" == "true" ] ; then
  ### DFS wieder aushängen, wenn in Script eingehängt
  umount /mnt/dfs
fi

echo ...Fertig