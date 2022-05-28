#!/bin/bash
# fhemdb_calc-and-message-daily.sh
# Carsten Söhrens, 12.12.2017

# Historie
# 12.12.2017 Initiale Version
# 24.02.2020 Erweiterung um insert-Statement auf der Datenbank, Kommentare ergänzt
# 25.02.2020 delete-Statement für die Tabelle current ergänzt, Debug echo-Statements entfernt
# 10.01.2022 Format für Angabe kW/h auf drei Nachkommastellen begrenzt
# 31.01.2022 delete-Statement für fehlerhafte Daten von ENERGY_Yesterday ergänzt
# 16.02.2022 Variablen für YDA und DBY umbenannt

TOKEN=312020795:AAHF3Uc_5L6mcn9hlo7oEhaDfZ5ypWCc3Mk
CHAT_ID=9437849
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
PSQL="/usr/bin/psql"
DBNAME="postgresql://fhem:fhem@localhost:5432/fhem"

# Das Datum von gestern (YDA) und vorgestern (DBY) berechnen
YESTERDAY=$(date -d "1 day ago" '+%d.%m.%Y')
YDA_ISO=$(date -d "1 day ago" '+%Y-%m-%d')
DBY_ISO=$(date -d "2 days ago" '+%Y-%m-%d')

# Fehlerhafte Daten für ENERGY_Yesterday am gestrigen und vorgestrigen Tag entfernen
DELETE=$($PSQL -X $DBNAME -t -c "delete from history where date_trunc('day', timestamp)= '$DBY_ISO' and device = 'MQTT2_DVES_0371A9' and reading = 'ENERGY_Yesterday' and timestamp !=(select min(timestamp) from history where date_trunc('day', timestamp)= '$DBY_ISO' and device = 'MQTT2_DVES_0371A9' and reading = 'ENERGY_Yesterday');")
DELETE=$($PSQL -X $DBNAME -t -c "delete from history where date_trunc('day', timestamp)= '$YDA_ISO' and device = 'MQTT2_DVES_0371A9' and reading = 'ENERGY_Yesterday' and timestamp !=(select min(timestamp) from history where date_trunc('day', timestamp)= '$YDA_ISO' and device = 'MQTT2_DVES_0371A9' and reading = 'ENERGY_Yesterday');")

# Abfrage der total_consumption für gestern und vorgestern aus der Datenbank
# "select distinct on" bestimmt den ersten Tupel einer Abfrage
TOTAL1=$($PSQL -X $DBNAME -t -c "SELECT DISTINCT ON (timestamp::date) value FROM history where reading='total_consumption' AND timestamp::date='$YDA_ISO' ORDER BY timestamp::date DESC, timestamp DESC;")
TOTAL2=$($PSQL -X $DBNAME -t -c "SELECT DISTINCT ON (timestamp::date) value FROM history where reading='total_consumption' AND timestamp::date='$DBY_ISO' ORDER BY timestamp::date DESC, timestamp DESC;")

# Verbrauch berechnen (dafür muss bc installiert sein -> apt install bc)
CONSUMPTION=$(bc <<< "$TOTAL1-$TOTAL2")
COSTS=$(bc <<< "$CONSUMPTION*0.25")

# Alte Datensätze mit reading 'daily_consumption' als current entfernen
# Verbrauch von gestern als zusätzliche Zeile in die Datenbank einfügen (current und history)
$PSQL -X $DBNAME -t -c "delete from current where reading='daily_consumption';"
$PSQL -X $DBNAME -t -c "insert into current (timestamp, device, type, event, reading, value, unit) values ('$(date -d "$YDA_ISO" "+%Y-%m-%d 23:59:59")', 'Stromzaehler', 'OBIS', 'daily_consumption: $CONSUMPTION', 'daily_consumption', $CONSUMPTION, '');"
$PSQL -X $DBNAME -t -c "delete from history where reading='daily_consumption' and timestamp >= '$YDA_ISO';"
$PSQL -X $DBNAME -t -c "insert into history (timestamp, device, type, event, reading, value, unit) values ('$(date -d "$YDA_ISO" "+%Y-%m-%d 23:59:59")', 'Stromzaehler', 'OBIS', 'daily_consumption: $CONSUMPTION', 'daily_consumption', $CONSUMPTION, '');"

# Bei Kosten und Verbrauch den Punkt (Decimal) durch Komma ersetzen
# Sieht dann besser in der Telegram-Message aus
CONSUMPTION=$(printf "%0.3f\n" $CONSUMPTION | sed 's/\./,/g')
COSTS=$(printf "%0.2f\n" $COSTS | sed 's/\./,/g')

# Nachricht für Telegram zusammensetzen
MESSAGE="Stromverbrauch $YESTERDAY: $CONSUMPTION kW/h (ca. $COSTS EUR)"

# Nachricht über Telegram absetzen
curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE"
