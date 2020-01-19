#!/bin/bash

TOKEN=312020795:AAHF3Uc_5L6mcn9hlo7oEhaDfZ5ypWCc3Mk
CHAT_ID=9437849
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
PSQL="/usr/bin/psql"
DBNAME="postgresql://fhem:fhem@localhost:5432/fhem"
TODAY=`date -d "1 day ago" '+%d.%m.%Y'`
TODAY1=`date -d "1 day ago" '+%Y-%m-%d'`
TODAY2=`date -d "2 days ago" '+%Y-%m-%d'`

TOTAL1=`$PSQL -X $DBNAME -t -c "SELECT DISTINCT ON (timestamp::date) value FROM history where reading='total_consumption' AND timestamp::date='$TODAY1' ORDER BY timestamp::date DESC, timestamp DESC;"`
TOTAL2=`$PSQL -X $DBNAME -t -c "SELECT DISTINCT ON (timestamp::date) value FROM history where reading='total_consumption' AND timestamp::date='$TODAY2' ORDER BY timestamp::date DESC, timestamp DESC;"`

#echo $TOTAL1
#echo $TOTAL2

CONSUMPTION=`bc <<< "$TOTAL1-$TOTAL2"`
COSTS=`bc <<< "$CONSUMPTION*0.25"`
CONSUMPTION=`echo $CONSUMPTION | sed 's/\./,/g'`
COSTS=`printf "%0.2f\n" $COSTS | sed 's/\./,/g'`

#echo $CONSUMPTION
#echo $COSTS

MESSAGE="Stromverbrauch $TODAY: $CONSUMPTION kW/h (ca. $COSTS EUR)"

#echo $MESSAGE
curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE"
