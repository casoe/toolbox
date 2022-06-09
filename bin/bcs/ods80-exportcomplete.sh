#!/bin/bash
# Name : ods80-export-complete.sh
# Autor: Carsten Söhrens

### Allgemeine Variablen
TODAY=`date +"%d.%m.%Y"`
STARTDATE="2016-01-01"
BCSHOME="/opt/projektron/bcs/server"
MONTHS=$(( (`date +%Y`-`date -d $STARTDATE +"%Y"`)*12 + `date +%-m`-`date -d $STARTDATE +"%-m"`))
echo $MONTHS Monate seit $STARTDATE

### Überprüfe, auf welcher Maschine das Skript ausgeführt wird
### Setzen des Hosts für die Datenbank entsprechend der Verbindung
MACHINE=`uname -n`
if [[ "$MACHINE" == 'bcs' ]]; then
	DATABASE=172.16.1.103
else
	DATABASE=localhost
fi

PSQL="psql postgresql://bcs@$DATABASE/ods80"
SCHEDULERCLIENT="/opt/projektron/bcs/server/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ExportJob"

### Für die Access Credentials wird .pgpass in home ausgewertet
### Droppen der BCS-bezogenen Tabellen und neues Erzeugen
$PSQL -f /opt/projektron/bcs/server/inform_scripts/ods-createbcstables.sql
$PSQL -f /opt/projektron/bcs/server/inform_scripts/ods-createdatevmonlisttables.sql

$PSQL_ODS80 << EOF
DROP TABLE IF EXISTS bcs_akquisen;
DROP TABLE IF EXISTS bcs_auftragsplan;
DROP TABLE IF EXISTS bcs_aufwandsplan;
DROP TABLE IF EXISTS bcs_eingangsrechnungen;
DROP TABLE IF EXISTS bcs_konferenzregistrierung;
DROP TABLE IF EXISTS bcs_organisationen;
DROP TABLE IF EXISTS bcs_projekte;
DROP TABLE IF EXISTS bcs_rechnungen;
DROP TABLE IF EXISTS bcs_sachkosten;
DROP TABLE IF EXISTS bcs_stundensaetze;
DROP TABLE IF EXISTS bcs_zahlungstermine;
DROP TABLE IF EXISTS datev_honorare;
DROP TABLE IF EXISTS datev_kosten;
DROP TABLE IF EXISTS datev_umsatz;
EOF


if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT could not execute $PSQL"
	exit 1;
}
fi;


### Die folgenden Exporte laufen erstmal komplett, weil vergleichweise schnell/performant
$SCHEDULERCLIENT -t JDBC_ODS80_Allowances
$SCHEDULERCLIENT -t JDBC_ODS80_Employees

### Schleife, um durch die relevanten Monate zu laufen
COUNTER=0
while [  $COUNTER -lt $MONTHS ]; do

	### Relevante Datumsangaben für den jeweiligen Monat und Name des Zielordners berechnen
	### 01.01.2016
	START=`date -d "$STARTDATE +$COUNTER month" +"%d.%m.%Y"`
	### 31.01.2016
	END=`date -d "$STARTDATE +$(($COUNTER+1)) month -1 day" +"%d.%m.%Y"`

	### Ein bisschen Ausgabe, was wir gerade machen
	echo Processing $START until $END
	
	### Export der Buchungen monatsweise, da sonst in einen Timeout gelaufen wird
	$SCHEDULERCLIENT -t JDBC_ODS80_Efforts "export.param.startdate=$START" "export.param.enddate=$END"

	### Export der Termine ebenfalls monatsweise, da diese immer Start und Ende brauchen
	$SCHEDULERCLIENT -t JDBC_ODS80_Appointments "export.param.startdate=$START" "export.param.enddate=$END"
	
	let COUNTER+=1
done

START=`date -d "-$(($(date +%d)-1)) days" +"%d.%m.%Y"`
END=`date -d "-1 days" +"%d.%m.%Y"`

### Abschließend noch einmal für den aktuellen Monat
echo Processing $START until $END

### Export der Buchungen monatsweise, da sonst in einen Timeout gelaufen wird
$SCHEDULERCLIENT -t JDBC_ODS80_Efforts "export.param.startdate=$START" "export.param.enddate=$END"

### Export der Termine ebenfalls monatsweise, da diese immer Start und Ende brauchen
$SCHEDULERCLIENT -t JDBC_ODS80_Appointments "export.param.startdate=$START" "export.param.enddate=$END"

### Berechtigungen setzen
sh $BCSHOME/inform_scripts/ods80-grantselect.sh
