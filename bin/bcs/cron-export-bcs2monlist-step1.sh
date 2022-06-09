#!/bin/bash
# Autor: Carsten Söhrens

### Setzen von Variablen
SCHEDULERCLIENT="/opt/projektron/bcs/server/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ExportJob"

### Einschränkung der Buchungen auf den Zeitraum des letzten Monats
### Relevante Datumsangaben berechnen, es wird z. Bsp. am 10.03.2022 vom 01.02.2022 bis 28.02.2022 exportiert
STARTDATE=`date -d "-1 month" +"01.%m.%Y"`
ENDDATE=`date -d "$(date +%Y-%m-01) -1 day" +"%d.%m.%Y"`

echo Starte Export...
$SCHEDULERCLIENT -t CSV_AllowancesExport-INFORM  "export.param.startdate=$STARTDATE" "export.param.enddate=$ENDDATE"
$SCHEDULERCLIENT -t CSV_AppointmentExport-INFORM "export.param.startdate=$STARTDATE" "export.param.enddate=$ENDDATE"
$SCHEDULERCLIENT -t CSV_DeputatUser-INFORM       "export.param.startdate=$STARTDATE" "export.param.enddate=$ENDDATE"
$SCHEDULERCLIENT -t CSV_EffortsExport-INFORM     "export.param.startdate=$STARTDATE" "export.param.enddate=$ENDDATE"

echo ...Fertig