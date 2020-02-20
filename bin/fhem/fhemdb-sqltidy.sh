#!/bin/bash
# Name : tidy-db.sh
# Autor: Carsten Söhrens

PSQL="psql postgresql://fhem@localhost/fhem"
TIME="2017-05-19 21:25:00"

COUNTER=0
while [  $COUNTER -lt 1440 ]; do

echo $TIME
$PSQL << EOF
delete from history
where date_trunc('minute', timestamp)= '$TIME'
    and reading='total_consumption'
    and value !=(
      select   max(value)
      from   history
      where  date_trunc('minute', timestamp)= '$TIME');
EOF

TIME=$(date -d "$TIME 1min" "+%Y-%m-%d %H:%M:00")
let COUNTER+=1

done
