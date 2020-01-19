#!/bin/bash
# Name : daily-export-bcs2ods.sh
# Autor: Carsten Söhrens

### Überprüfe, auf welcher Maschine das Skript ausgeführt wird
### Setzen des Hosts für die Datenbank entsprechend der Verbindung
MACHINE=`uname -n`
if [[ "$MACHINE" == 'bcs' ]]; then
	DATABASE=172.16.1.103
else
	DATABASE=localhost
fi

SCRIPT="daily-export-bcs2ods.sh"
PSQL_ODS30="psql postgresql://bcs@$DATABASE/ods30"
PSQL_ODS70="psql postgresql://bcs@$DATABASE/ods70"
PSQL_ODS80="psql postgresql://bcs@$DATABASE/ods80"
SCHEDULERCLIENT="/opt/projektron/bcs/server/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ExportJob"

### Für die Access Credentials wird .pgpass in home ausgewertet
### Delete alter Daten
echo "ODS30: Delete alter Daten der Tabellen, die komplett abgeräumt werden"
$PSQL_ODS30 << EOF
delete from bcs_akquisen;
delete from bcs_auftragsplan;
delete from bcs_aufwandsplan;
delete from bcs_konferenzregistrierung;
delete from bcs_mitarbeiter;
delete from bcs_organisationen;
delete from bcs_projekte;
delete from bcs_rechnungen;
delete from bcs_spesen;
delete from bcs_stundensaetze;
delete from bcs_zahlungstermine;
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not execute $PSQL_ODS30"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

echo "ODS70: Delete alter Daten der Tabellen, die komplett abgeräumt werden"
$PSQL_ODS70 << EOF
delete from bcs_akquisen;
delete from bcs_auftragsplan;
delete from bcs_aufwandsplan;
delete from bcs_konferenzregistrierung;
delete from bcs_mitarbeiter;
delete from bcs_organisationen;
delete from bcs_projekte;
delete from bcs_rechnungen;
delete from bcs_spesen;
delete from bcs_stundensaetze;
delete from bcs_zahlungstermine;
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not execute $PSQL_ODS70"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

echo "ODS80: Delete alter Daten der Tabellen, die komplett abgeräumt werden"
$PSQL_ODS80 << EOF
delete from bcs_mitarbeiter;
delete from bcs_spesen;
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not execute $PSQL_ODS80"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;


### Schleife über die letzten drei Monate inkl. des aktuellen Monats
### Delete der Daten für Buchungen und Termine in diesem Bereich
echo "ODS30: Delete der Daten für Buchungen und Termine in den letzten 3 Monaten"
for i in `seq 0 3`;
do
		MONTH=`date -d "-$i month -$(($(date +%d | sed 's/^0//g')-1)) days" +"%m.%Y"`
		echo $MONTH
		$PSQL_ODS30 -c "delete from bcs_buchungen where datum like '%$MONTH';"
		$PSQL_ODS30 -c "delete from bcs_termine where datum like '%$MONTH';"
done

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not execute $PSQL_ODS30"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

echo "ODS70: Delete der Daten für Buchungen und Termine in den letzten 3 Monaten"
for i in `seq 0 3`;
do
		MONTH=`date -d "-$i month -$(($(date +%d | sed 's/^0//g')-1)) days" +"%m.%Y"`
		echo $MONTH
		$PSQL_ODS70 -c "delete from bcs_buchungen where datum like '%$MONTH';"
		$PSQL_ODS70 -c "delete from bcs_termine where datum like '%$MONTH';"
done

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not execute $PSQL_ODS70"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

echo "ODS80: Delete der Daten für Buchungen und Termine in den letzten 3 Monaten"
for i in `seq 0 3`;
do
		MONTH=`date -d "-$i month -$(($(date +%d | sed 's/^0//g')-1)) days" +"%m.%Y"`
		echo $MONTH
		$PSQL_ODS80 -c "delete from bcs_buchungen where datum like '%$MONTH';"
		$PSQL_ODS80 -c "delete from bcs_termine where datum like '%$MONTH';"
done

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not execute $PSQL_ODS80"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

### Die folgenden Exporte laufen erstmal komplett, weil vergleichweise schnell/performant
echo "ODS30: Komplette Exporte für die Tabellen, die vergleichweise schnell/performant befüllt werden können"
$SCHEDULERCLIENT -t JDBC_ODS30_Acquisitions
$SCHEDULERCLIENT -t JDBC_ODS30_Allowances
$SCHEDULERCLIENT -t JDBC_ODS30_Conferenceregistrations
$SCHEDULERCLIENT -t JDBC_ODS30_Costrates
$SCHEDULERCLIENT -t JDBC_ODS30_Effortplan
$SCHEDULERCLIENT -t JDBC_ODS30_Employees
$SCHEDULERCLIENT -t JDBC_ODS30_Invoices
$SCHEDULERCLIENT -t JDBC_ODS30_Orderplan
$SCHEDULERCLIENT -t JDBC_ODS30_Organisations
$SCHEDULERCLIENT -t JDBC_ODS30_Paymentdays
$SCHEDULERCLIENT -t JDBC_ODS30_Projects

echo "ODS70: Komplette Exporte für die Tabellen, die vergleichweise schnell/performant befüllt werden können"
$SCHEDULERCLIENT -t JDBC_ODS70_Acquisitions
$SCHEDULERCLIENT -t JDBC_ODS70_Allowances
$SCHEDULERCLIENT -t JDBC_ODS70_Conferenceregistrations
$SCHEDULERCLIENT -t JDBC_ODS70_Costrates
$SCHEDULERCLIENT -t JDBC_ODS70_Effortplan
$SCHEDULERCLIENT -t JDBC_ODS70_Employees
$SCHEDULERCLIENT -t JDBC_ODS70_Invoices
$SCHEDULERCLIENT -t JDBC_ODS70_Orderplan
$SCHEDULERCLIENT -t JDBC_ODS70_Organisations
$SCHEDULERCLIENT -t JDBC_ODS70_Paymentdays
$SCHEDULERCLIENT -t JDBC_ODS70_Projects

echo "ODS80: Komplette Exporte für die Tabellen, die vergleichweise schnell/performant befüllt werden können"
$SCHEDULERCLIENT -t JDBC_ODS80_Allowances
$SCHEDULERCLIENT -t JDBC_ODS80_Employees

### Einschränkung der Buchungen auf den Zeitraum der letzten drei Monate bis gestern
### Relevante Datumsangaben berechnen, es wird z. Bsp. am 14.09.2017 vom 01.06.2017 bis 13.09.2017 exportiert
STARTDATE=`date -d "-3 month -$(($(date +%d | sed 's/^0//g')-1)) days" +"%d.%m.%Y"`
ENDDATE=`date -d "-1 days" +"%d.%m.%Y"`
echo "ODS30: Exporte der letzten 3 Monate für Buchungen und Termine"
$SCHEDULERCLIENT -t JDBC_ODS30_Efforts "export.param.startdate=$STARTDATE" "export.param.enddate=$ENDDATE"

### Termine müssen immer mit Start- und Endeparameter übergeben werden (der Einfachheit halber hier auch die letzten drei Monate bis gestern)
$SCHEDULERCLIENT -t JDBC_ODS30_Appointments "export.param.startdate=$STARTDATE" "export.param.enddate=$ENDDATE"

echo "ODS70: Exporte der letzten 3 Monate für Buchungen und Termine"
$SCHEDULERCLIENT -t JDBC_ODS70_Efforts "export.param.startdate=$STARTDATE" "export.param.enddate=$ENDDATE"

### Termine müssen immer mit Start- und Endeparameter übergeben werden (der Einfachheit halber hier auch die letzten drei Monate bis gestern)
$SCHEDULERCLIENT -t JDBC_ODS70_Appointments "export.param.startdate=$STARTDATE" "export.param.enddate=$ENDDATE"

echo "ODS80: Exporte der letzten 3 Monate für Buchungen und Termine"
$SCHEDULERCLIENT -t JDBC_ODS80_Efforts "export.param.startdate=$STARTDATE" "export.param.enddate=$ENDDATE"

### Termine müssen immer mit Start- und Endeparameter übergeben werden (der Einfachheit halber hier auch die letzten drei Monate bis gestern)
$SCHEDULERCLIENT -t JDBC_ODS80_Appointments "export.param.startdate=$STARTDATE" "export.param.enddate=$ENDDATE"