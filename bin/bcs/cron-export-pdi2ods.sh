#!/bin/bash
# Name : daily-export-pdi2ods.sh
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
PSQL_ODS70="psql postgresql://bcs@$DATABASE/ods70"
PSQL_ODS80="psql postgresql://bcs@$DATABASE/ods80"
KITCHEN="/opt/projektron/bcs/data-integration/kitchen.sh"
AWK=/usr/bin/awk
STATISTICS_LOG=/opt/projektron/bcs/server/log/inform_cron/daily-export-pdi2ods-statistics.csv

MONLIST_GB30="/opt/projektron/bcs/server/inform_etl/monlist2ods30.kjb"
DATEV_GB30="/opt/projektron/bcs/server/inform_etl/datev2ods30.kjb"

MONLIST_GB70="/opt/projektron/bcs/server/inform_etl/monlist2ods70.kjb"
DATEV_GB70="/opt/projektron/bcs/server/inform_etl/datev2ods70.kjb"

MONLIST_GB80="/opt/projektron/bcs/server/inform_etl/monlist2ods80.kjb"

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

### Schreibe Zeitstempel der importierten Dateien und die aktuelle Differenz in Tagen zur Systemzeit in eine CSV-Datei
ls -la --time-style=long-iso /mnt/dfs/Global/GB30/*$(date +"%Y")* | grep 'Fre\|Kost\|Umsatz\|Ver' |grep -v 'gb30' |grep -v '\$' |\
$AWK '{
	# Systemzeit holen
	date=systime();
	# Stunden und Minuten loswerden bzw. auf 0 setzen
	d1=mktime(strftime("%Y %m %d 00 00 00",date));
	# Zeitstempel aus ls so umformatieren, dass mktime funktioniert
	d2=$6" "$7":00";
	gsub(/[-:]/," ",d2);
	# Stunden und Minuten loswerden bzw. auf 0 setzen
	d2=mktime(strftime("%Y %m %d 00 00 00",mktime(d2)));
	# Ausgabe der berechneten und formatierten Werte
	print strftime("%Y-%m-%d;%H:%M",date)";"$6";"$7";"$8";"(d1-d2)/86400}' >> $STATISTICS_LOG

ls -la --time-style=long-iso /mnt/dfs/Global/GB70/*$(date +"%Y")* | grep 'Fre\|Kost\|Umsatz\|Ver' |grep -v 'gb70' |grep -v '\$' |\
$AWK '{
	# Systemzeit holen
	date=systime();
	# Stunden und Minuten loswerden bzw. auf 0 setzen
	d1=mktime(strftime("%Y %m %d 00 00 00",date));
	# Zeitstempel aus ls so umformatieren, dass mktime funktioniert
	d2=$6" "$7":00";
	gsub(/[-:]/," ",d2);
	# Stunden und Minuten loswerden bzw. auf 0 setzen
	d2=mktime(strftime("%Y %m %d 00 00 00",mktime(d2)));
	# Ausgabe der berechneten und formatierten Werte
	print strftime("%Y-%m-%d;%H:%M",date)";"$6";"$7";"$8";"(d1-d2)/86400}' >> $STATISTICS_LOG

### Kopiere GB30-Datev-Exporte für die Datenintegration
cp -v /mnt/dfs/Global/GB30/Fre3-*    /opt/projektron/bcs/server/inform_etl/datev/gb30/
cp -v /mnt/dfs/Global/GB30/Kost3-*   /opt/projektron/bcs/server/inform_etl/datev/gb30/
cp -v /mnt/dfs/Global/GB30/Umsatz3-* /opt/projektron/bcs/server/inform_etl/datev/gb30/
cp -v /mnt/dfs/Global/GB30/Ver3-*    /opt/projektron/bcs/server/inform_etl/datev/gb30/

### Kopiere GB70-Datev-Exporte für die Datenintegration
cp -v /mnt/dfs/Global/GB70/Fre7-*    /opt/projektron/bcs/server/inform_etl/datev/gb70/
cp -v /mnt/dfs/Global/GB70/Kost7-*   /opt/projektron/bcs/server/inform_etl/datev/gb70/
cp -v /mnt/dfs/Global/GB70/Umsatz7-* /opt/projektron/bcs/server/inform_etl/datev/gb70/
cp -v /mnt/dfs/Global/GB70/Ver7-*    /opt/projektron/bcs/server/inform_etl/datev/gb70/

### DFS wieder aushängen
umount /mnt/dfs

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not unmount $MOUNTDIR"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

### Für die Access Credentials wird .pgpass in home ausgewertet
### Delete alter Daten, Bestand wird für Monlist und DATEV immer komplett neu aufgebaut
$PSQL_ODS30 << EOF
delete from monlist_buchungen;
delete from monlist_deckblaetter;
delete from monlist_personal;
delete from monlist_projekte;
delete from monlist_urlaub;
delete from datev_umsatz;
delete from datev_kosten;
delete from datev_honorare;
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not execute $PSQL_ODS30"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

$PSQL_ODS70 << EOF
delete from monlist_buchungen;
delete from monlist_deckblaetter;
delete from monlist_personal;
delete from monlist_projekte;
delete from monlist_urlaub;
delete from datev_umsatz;
delete from datev_kosten;
delete from datev_honorare;
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not execute $PSQL_ODS70"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

$PSQL_ODS80 << EOF
delete from monlist_buchungen;
delete from monlist_deckblaetter;
delete from monlist_personal;
delete from monlist_projekte;
delete from monlist_urlaub;
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not execute $PSQL_ODS80"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

$KITCHEN -file=$MONLIST_GB30
$KITCHEN -file=$DATEV_GB30
$KITCHEN -file=$MONLIST_GB70
$KITCHEN -file=$DATEV_GB70
$KITCHEN -file=$MONLIST_GB80

# Nachbearbeitung/Korrektur/Ergänzung der Daten nach der Integration
$PSQL_ODS30 -f /opt/projektron/bcs/server/inform_scripts/ods30-pdi2ods-postprocessing.sql
$PSQL_ODS70 -f /opt/projektron/bcs/server/inform_scripts/ods70-pdi2ods-postprocessing.sql