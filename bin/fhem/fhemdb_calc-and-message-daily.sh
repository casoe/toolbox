#!/bin/bash
# fhemdb_calc-and-message-daily.sh
# Carsten Söhrens, 12.12.2017

# Historie
# 12.12.2017 Initiale Version
# 24.02.2020 Erweiterung um insert-Statement auf der Datenbank, Kommentare ergänzt
# 25.02.2020 delete-Statement für die Tabelle current ergänzt, Debug echo-Statements entfernt

TOKEN=312020795:AAHF3Uc_5L6mcn9hlo7oEhaDfZ5ypWCc3Mk
CHAT_ID=9437849
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
PSQL="/usr/bin/psql"
DBNAME="postgresql://fhem:fhem@localhost:5432/fhem"

# Das Datum von gestern und vorgestern berechnen
TODAY=`date -d "1 day ago" '+%d.%m.%Y'`
TODAY1=`date -d "1 day ago" '+%Y-%m-%d'`
TODAY2=`date -d "2 days ago" '+%Y-%m-%d'`

# Abfrage der total_consumption für gestern und vorgestern aus der Datenbank
# "select distinct on" bestimmt den ersten Tupel einer Abfrage
TOTAL1=`$PSQL -X $DBNAME -t -c "SELECT DISTINCT ON (timestamp::date) value FROM history where reading='total_consumption' AND timestamp::date='$TODAY1' ORDER BY timestamp::date DESC, timestamp DESC;"`
TOTAL2=`$PSQL -X $DBNAME -t -c "SELECT DISTINCT ON (timestamp::date) value FROM history where reading='total_consumption' AND timestamp::date='$TODAY2' ORDER BY timestamp::date DESC, timestamp DESC;"`

# Verbrauch berechnen (dafür muss bc installiert sein -> apt install bc)
CONSUMPTION=`bc <<< "$TOTAL1-$TOTAL2"`
COSTS=`bc <<< "$CONSUMPTION*0.25"`

# Alte Datensätze mit reading 'daily_consumption' als current entfernen
# Verbrauch von gestern als zusätzliche Zeile in die Datenbank einfügen (current und history)
$PSQL -X $DBNAME -t -c "delete from current where reading='daily_consumption';"
$PSQL -X $DBNAME -t -c "insert into current (timestamp, device, type, event, reading, value, unit) values ('$(date -d "$TODAY1" "+%Y-%m-%d 23:59:59")', 'Stromzaehler', 'OBIS', 'daily_consumption: $CONSUMPTION', 'daily_consumption', $CONSUMPTION, '');"
$PSQL -X $DBNAME -t -c "insert into history (timestamp, device, type, event, reading, value, unit) values ('$(date -d "$TODAY1" "+%Y-%m-%d 23:59:59")', 'Stromzaehler', 'OBIS', 'daily_consumption: $CONSUMPTION', 'daily_consumption', $CONSUMPTION, '');"

# Bei Kosten und Verbrauch den Punkt (Decimal) durch Komma ersetzen
# Sieht dann besser in der Telegram-Message aus
CONSUMPTION=`echo $CONSUMPTION | sed 's/\./,/g'`
COSTS=`printf "%0.2f\n" $COSTS | sed 's/\./,/g'`

# Nachricht für Telegram zusammensetzen
MESSAGE="Stromverbrauch $TODAY: $CONSUMPTION kW/h (ca. $COSTS EUR)"

# Nachricht über Telegram absetzen
curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE"
