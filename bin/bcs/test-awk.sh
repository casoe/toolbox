#!/bin/bash
# Autor: Carsten Söhrens

FULLDATE=`date +\%Y-\%m-\%d`
BCSLOGDIR="/opt/projektron/bcs/server/log/inform_cron"
AWK=/usr/bin/awk

set -x

# Check, ob die DATEV-Exporte zu alt sind (>5 Tage)
if [[ $(grep $FULLDATE $BCSLOGDIR/daily-export-pdi2ods-statistics.csv |$AWK -F ';' '$6>5') ]]; then
	echo 'ACHTUNG: DATEV-Exporte veraltet (>5 Tage)'
	grep $FULLDATE $BCSLOGDIR/daily-export-pdi2ods-statistics.csv | $AWK -F ';' '$6>5' | column -t -s $';' -n "$@"
fi
