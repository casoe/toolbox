#!/bin/bash
# Name : import-payedinvoices-datev-gb30.sh
# Autor: Jan-Michael Regulski
# Aufgaben:
# - Kopie: Einschränkung auf bestimmte Dateien (Jahr?)
# - Pfadnamen der zu bearbeitenden Dateien
# - Logdateien mit importierte Datensätze abspeichern; ist das möglich; wenn nicht. evt. Einstellung in XML auf Logging belassen

PYTHON="/usr/local/bin/python3.9"

SUPPORTMAIL="bcs-support@inform-software.com"

SCRIPT="cron-import-payedinvoices-datev.sh"
BCSHOME="/opt/projektron/bcs/server"
BCSIMPORT="/opt/projektron/bcs/import"
SOURCEDIR="Global/GB30"
TARGETDIR="/opt/projektron/bcs/datev/archiv-bezahlte-rechnungen"
SCRIPDIR="inform_scripts"
MOUNTDIR="/mnt/dfs"

exortfileprefix="AllePosten"
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
if [ -f $MOUNTDIR/$SOURCEDIR/$exortfileprefix.xlsx ] ; then

    test_input=$(stat -c %y $MOUNTDIR/$SOURCEDIR/$exortfileprefix.xlsx)
    test_backup=$(cat $TARGETDIR/.timestamp_AllePosten)
    ###Test, ob Datei sich geändert hat
    if ! [ "$test_input" == "$test_backup" ] ; then

        ###Kopieren der AllePosten-Datei
        echo "Kopieren der Quelldatei auf den BCS-Server..."
        cp -f -v -a $MOUNTDIR/$SOURCEDIR/$exortfileprefix.xlsx $BCSIMPORT

        ###Sichern des neuen Datums
        stat -c %y $BCSIMPORT/$exortfileprefix.xlsx > $TARGETDIR/.timestamp_AllePosten

        ###Konvertieren der Import-Exceldatei nach CSV
        echo "Konvertieren der Quelldatei nach CSV..."
        in2csv -e "UTF8" -v $BCSIMPORT/$exortfileprefix.xlsx | csvformat -D ";" > $BCSIMPORT/$exortfileprefix.csv

        ###Analysieren der Zahlungen durch Gruppierung nach Rechnungsnummer
        echo "ETL der Quelldatei..."
        $PYTHON $BCSHOME/$SCRIPDIR/GroupInvoicesByNumber.py $BCSIMPORT/$exortfileprefix.csv $BCSIMPORT/$exortfileprefix-aggregated.csv

        ### Import anstoßen
        echo "Starte Import..."
        $BCSHOME/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ImportJob -t CSV_PayedInvoices

        ### Wait for 60 seconds
        sleep 60s

        ###Verschieben der Importdateien
        ###Importdateien in das Archivierungsverzeichnis kopieren, Zeit hinzufügen zur Unterscheidung der einzelnen Vorgänge
        ###Logdatei wird nicht komplett sein, da bereits hier gezippt
        echo "Archiviere und verschiebe alle Dateien (Liste nicht komplett da Log-Datei weggezippt)..."
        zip -r -m -j -9 $TARGETDIR/$exortfileprefix$FULLDATE-$FULLTIME.zip $BCSIMPORT/$exortfileprefix*
        zip -r -j -9 $TARGETDIR/$exortfileprefix$FULLDATE-$FULLTIME.zip $BCSHOME/log/bcs-application-detailed.log
    else
        echo "AllePosten-Datei bereits verarbeitet. Kein erneuter Import"
    fi
    

else
    echo "Keine AllePosten-Datei zum Kopieren vorhanden"
fi

if [ "$mountcheck" == "true" ] ; then
  ### DFS wieder aushängen, wenn in Script eingehängt
  umount /mnt/dfs
fi

echo ...Fertig