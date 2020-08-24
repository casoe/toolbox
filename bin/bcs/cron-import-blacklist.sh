#!/bin/bash
# Name : daily-import-blacklist.sh
# Autor: Carsten Söhrens

### Import anstoßen
/opt/projektron/bcs/server/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ImportJob -t JDBC_UserCrmBlacklistContact
/opt/projektron/bcs/server/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ImportJob -t JDBC_UserCrmBlacklistLead
