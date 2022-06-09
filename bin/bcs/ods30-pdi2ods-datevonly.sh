#!/bin/bash
# Name : ods30-pdi2ods-datevonly.sh
# Autor: Carsten Söhrens

### Überprüfe, auf welcher Maschine das Skript ausgeführt wird
### Setzen des Hosts für die Datenbank entsprechend der Verbindung
MACHINE=`uname -n`
if [[ "$MACHINE" == 'bcs' ]]; then
	DATABASE=172.16.1.103
else
	DATABASE=localhost
fi

### Setze weitere Variablen
SCRIPT="daily-export-pdi2ods.sh"
MOUNTDIR="/mnt/dfs"
PSQL_ODS30="psql postgresql://bcs@$DATABASE/ods30"
KITCHEN="/opt/projektron/bcs/data-integration/kitchen.sh"
DATEV_GB30="/opt/projektron/bcs/server/inform_etl/datev2ods30.kjb"

### Mount DFS volume, if problem send mail and abort
if [ ! $(mount | grep -o $MOUNTDIR ) ]; then
{
	mount -v -t cifs //intern.inform-software.com/files $MOUNTDIR -o vers=3.0,rw,credentials=/root/.cifs,noserverino
}
fi;

### Kopiere GB30-Datev-Exporte für die Datenintegration
cp -v $MOUNTDIR/Global/GB30/Fre3-*    /opt/projektron/bcs/server/inform_etl/datev/gb30/
cp -v $MOUNTDIR/Global/GB30/Kost3-*   /opt/projektron/bcs/server/inform_etl/datev/gb30/
cp -v $MOUNTDIR/Global/GB30/Umsatz3-* /opt/projektron/bcs/server/inform_etl/datev/gb30/
cp -v $MOUNTDIR/Global/GB30/Ver3-*    /opt/projektron/bcs/server/inform_etl/datev/gb30/

### DFS wieder aushängen
umount $MOUNTDIR

### Für die Access Credentials wird .pgpass in home ausgewertet
### Delete alter Daten, Bestand wird für Monlist und DATEV immer komplett neu aufgebaut
$PSQL_ODS30 << EOF
delete from datev_umsatz;
delete from datev_kosten;
delete from datev_honorare;
EOF

$KITCHEN -file=$DATEV_GB30

# Nachbearbeitung/Korrektur/Ergänzung der Daten nach der Integration
$PSQL_ODS30 -f /opt/projektron/bcs/server/inform_scripts/ods30-pdi2ods-postprocessing.sql
