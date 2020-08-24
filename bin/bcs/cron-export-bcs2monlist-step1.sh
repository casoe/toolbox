#!/bin/bash
# Autor: Carsten Söhrens

echo Starte Export...
/opt/projektron/bcs/server/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ExportJob -t CSV_AllowancesExport-INFORM-Cronjob
/opt/projektron/bcs/server/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ExportJob -t CSV_AppointmentExport-INFORM-Cronjob
/opt/projektron/bcs/server/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ExportJob -t CSV_DeputatUser-INFORM-Cronjob
/opt/projektron/bcs/server/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ExportJob -t CSV_EffortsExport-INFORM-Cronjob

echo ...Fertig
