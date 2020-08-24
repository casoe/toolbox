#!/bin/bash
# Name : daily-import-exchangerates.sh
# Autor: Carsten Söhrens
# Erweiterung Berechnung weiterer Wechselkurse: Jan-Michael

### Proxy muss konfiguriert werden, sonst funktioniert das Skript über cron nicht
export http_proxy=http://proxy:80/
export https_proxy=$http_proxy
export ftp_proxy=$http_proxy
export rsync_proxy=$http_proxy
export no_proxy="localhost,127.0.0.1,.inform-software.com"

### Variablen setzen
TODAY=`date +"%d.%m.%Y"`
TODAY2=`date +"%Y-%m-%d"`
#TODAY2="2018-08-15"
#TODAY="15.08.2018"

STARTDATE="2015-01-01"
MONTHS=$(( (`date +%Y`-`date -d $STARTDATE +"%Y"`)*12 + `date +%-m`-`date -d $STARTDATE +"%-m"`))
echo $STARTDATE
echo $MONTHS
let MONTHS+=1

###zu ermittelnde Währungen:
### Währungen, deren Wechselkurse mit Euro herunterzuladen sind
DownloadedCur=(aud cad chf czk gbp hkd rub sek brl usd)

### Währungen, deren Umrechnungskurse zu berechnen sind:
declare -A CalculatedCur
###Array-Index: zu berechnende Quellwährung, Wert: Semikolon-separierte Liste der zugehörigen Zielwährungen
###Achtung: beim Import werden automatisch beide Richtungen angelegt (A:B und B:A), hier deswegen nur eine Richtung berücksichtigen
CalculatedCur[cad]="usd"
#CalculatedCur[aud]="usd;hkd;sek"
#CalculatedCur[hkd]="usd"


### Wechsel in das Arbeitsverzeichnis
cd /opt/projektron/bcs/exchangerates

### Ordner erzeugen, sofern nicht vorhanden
mkdir -p archive
mkdir -p csv
mkdir -p xml

### Zielfile mit allen Umrechungskursen mit dem Header eröffnen
echo 'sourceCurrency;targetCurrency;startDate;exchangeRate' > import.csv

### Schleife über alle relevanten Währungen
### USD muss zum Schluss kommen, da anschließend Qatar Riyal aus dem USD berechnet werden
for CURRENCY in ${DownloadedCur[*]}
do
  ### Zwischenspeicher leeren
  rm -rf temp.csv

  ### Download der Umrechungskurse als XML von der EZB
  # wget https://www.ecb.europa.eu/stats/exchange/eurofxref/html/$CURRENCY.xml -O xml/$CURRENCY.xml
  wget https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/$CURRENCY.xml -O xml/$CURRENCY.xml

  ### Umwandeln in csv-Dateien
	### Paket xml2 - Convert between XML, HTML, CSV and a line-oriented format
  xml2 < xml/$CURRENCY.xml | 2csv Obs @TIME_PERIOD @OBS_VALUE |sed 's/,/;/g' | sed 's/\./,/g' > csv/temp.csv
  echo 'startDate;exchangeRate' > csv/$CURRENCY.csv
  cat csv/temp.csv | awk -F'[-;]' '{print $3"."$2"."$1";"$4}' >> csv/$CURRENCY.csv

  ### Berechnung der notwendigen Umläufe und Filtern der Daten auf die relevanten Monate
  ### Das erzeugte File import.csv umfasst immer alle Umrechungskurse ab dem 01.01.2015
  COUNTER=0

  while [ $COUNTER -lt $MONTHS ]; do

    MATCH=`date -d "$STARTDATE +$COUNTER month" +"%m.%Y"`
    ### Variante #1: Nur der erste Match jeden Monats
    # grep -m 1 -e $MATCH csv/$CURRENCY.csv >> temp.csv

    ### Variante #2: Alle Daten der relevanten Monate
    grep -e $MATCH csv/$CURRENCY.csv >> temp.csv
    let COUNTER+=1
  done

  ### Zusätzliche Spalten links ankleben, dabei die Zielwährung in Uppercase
  awk -v curr=$CURRENCY '{ print "EUR;" toupper(curr) ";" $1 }' temp.csv >> import.csv

  ### Aufräumen
  rm -f csv/temp.csv

done

### Nachverarbeitung für QAR auf der Basis von USD (-> temp.csv)
### Vorverarbeitung, damit awk rechnen kann
sed -i 's/\./-/g' temp.csv
sed -i 's/,/\./g' temp.csv

### Umrechung mit festem Faktor 3,64
cat temp.csv | awk -F'[;]' '{print "EUR;QAR;" $1 ";" $2*3.64}' > temp2.csv

### Nochmal Komma und Bindestriche umbobbeln
sed -i 's/\./,/g' temp2.csv
sed -i 's/-/\./g' temp2.csv

### Anhängen der QAR-Umrechungskruse an den Import
cat temp2.csv >> import.csv

### Aufräumen
rm -f csv/temp.csv
rm -f temp.csv
rm -f temp2.csv

### Spezfisches File für den heutigen Tag erzeugen
echo 'sourceCurrency;targetCurrency;startDate;exchangeRate' > /opt/projektron/bcs/import/exchangerates_$TODAY2.csv
grep $TODAY import.csv >> /opt/projektron/bcs/import/exchangerates_$TODAY2.csv

###Wechselkurse berechnen
for itemindex in ${!CalculatedCur[*]}
do

	###Durchlauf 1: Kurs der zu bearbeitenden Währung heraussuchen
	consideredCur=""
	while read line; do    
		IFS=';' read -ra rate <<<$line; declare -a rate;
		###links: gibt Index (=Währung) von itemindex aus, rechts liest Zielwährung aus
		if [ "${itemindex,,}" == "${rate[1],,}" ] && [ "${rate[0],,}" == "eur" ]
		then
		   consideredCur=${rate[1]}
		   consideredRate=${rate[3]}	   
		   echo "Considered Source Currency/ Rate: $consideredCur/ $consideredRate"
		fi
	done < /opt/projektron/bcs/import/exchangerates_$TODAY2.csv

	#nur weiter wenn auch definiert	
	if [ ! -z "$consideredCur" ]
	then
		while read line; do    
			IFS=';' read -ra rate <<<$line; declare -a rate;
			###Nur Währungen aus zugehörigen Werten des CalculatedCur-Array gültig
				if [ ${CalculatedCur[$itemindex]//${rate[1],,}/,,} != "${CalculatedCur[$itemindex],,}" ] && [ "${rate[0],,}" == "eur" ]
				then 
				   echo "Target Currency/ Rate: ${rate[1]}/ ${rate[3]}"
				   ###Zum Rechnen Komma gegen Punkt getauscht
				   newRate=$(awk -v var2=${consideredRate//,/.} -v var1=${rate[3]//,/.} 'BEGIN { print  ( var1 / var2 ) }')
				   ###Schreiben der neuen Zeilen
				   echo "$consideredCur;${rate[1]};${rate[2]};${newRate//./,}" >> CalculatedRates.csv
				   echo "-> calculated rate: $newRate"
				fi
		done < /opt/projektron/bcs/import/exchangerates_$TODAY2.csv
	fi

done

if [ -f "CalculatedRates.csv" ]; then
	cat CalculatedRates.csv >> /opt/projektron/bcs/import/exchangerates_$TODAY2.csv
	rm -f CalculatedRates.csv
fi

### Archivieren der Kurse des zu importierenden Tages
cp /opt/projektron/bcs/import/exchangerates_$TODAY2.csv /opt/projektron/bcs/exchangerates/archive/
cat /opt/projektron/bcs/import/exchangerates_$TODAY2.csv

### Import anstoßen
/opt/projektron/bcs/server/bin/SchedulerClient.sh -u cron -p e6c92f3411 -j ImportJob -t CSV_Import_Exchangerates-INFORM
