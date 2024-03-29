#!/bin/bash
# Name : hourly-export-bcs2ods-paymentdays.sh
# Autor: Carsten Söhrens

source /opt/projektron/bcs/server/inform_scripts/my-functions.sh

### Überprüfe, auf welcher Maschine das Skript ausgeführt wird
### Setzen des Hosts für die Datenbank entsprechend der Verbindung
MACHINE=`uname -n`
if [[ "$MACHINE" == 'bcs' ]]; then
	DATABASE=172.16.1.103
else
	DATABASE=localhost
fi

SCRIPT="hourly-export-bcs2ods-paymentdays.sh"
PSQL_ODS30="psql postgresql://bcs@$DATABASE/ods30"
PSQL_ODS70="psql postgresql://bcs@$DATABASE/ods70"
SCHEDULERCLIENT="/opt/projektron/bcs/server/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ExportJob"

echolog "Hourly export of paymentdays started (GB70-only)"

### Für die Access Credentials wird .pgpass in home ausgewertet
### Delete alter Daten
#echolog "OD370: Delete der Zahlungstermine-Tabelle"
#$PSQL_ODS30 << EOF
#delete from bcs_zahlungstermine;
#EOF

#if [ $? -ne 0 ]; then
#{
#	echo "Error: $SCRIPT could not execute $PSQL_ODS30"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
#	exit 1;
#}
#fi;

#echolog "ODS30: Trigger des Exports der Akquisen-Tabelle"
#$SCHEDULERCLIENT -t JDBC_ODS30_Paymentdays

echolog "ODS70: Delete der Zahlungstermine-Tabelle"
$PSQL_ODS70 << EOF
delete from bcs_zahlungstermine;
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not execute $PSQL_ODS70"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

echolog "ODS70: Trigger des Exports der Akquisen-Tabelle"
$SCHEDULERCLIENT -t JDBC_ODS70_Paymentdays
