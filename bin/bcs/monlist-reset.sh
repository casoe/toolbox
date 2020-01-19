#!/bin/bash
# Name : monlist-reset.sh
# Autor: Carsten Söhrens
# Version für das Live-System

# Variablen setzen
NUMBER=$1
FULLDATE=`date +\%Y-\%m-\%d`
WORKDIR=/opt/projektron/bcs/monlist
MONTH=`date +'%m' -d 'last month' | sed 's/^0//g'`
#YEAR=`date +'%Y'`
YEAR=`date +'%Y' -d 'last month' | sed 's/^0//g'`

# Test, ob Parameter übergeben wurde
if [ $1 ] ; then
  echo Personalnummer erkannt, reset.json wird erzeugt

	# Patchen der reset.json auf der Basis einer Vorlage
	#cp reset.template reset.json
	#sed -i 's/SED_NUMBER/'"$NUMBER"'/g' reset.json
	#sed -i 's/SED_MONTH/'"$MONTH"'/g' reset.json
	#sed -i 's/SED_YEAR/'"$YEAR"'/g' reset.json

	# Schreiben der reset.json
	echo [ > $WORKDIR/reset.json
	echo \ \ { \"Nummer\": $NUMBER, \"Monat\": $MONTH, \"Jahr\": $YEAR } >> $WORKDIR/reset.json
	echo ] >> $WORKDIR/reset.json
	echo >> $WORKDIR/reset.json

# Ohne Parameter Abfrage, ob die reset.json direkt verarbeitet werden soll
else
  read -p "reset.json direkt ohne Anpassung verarbeiten? (J/N)" choice
        case "$choice" in
          J ) echo "Weiter...";;
          * ) echo "Abbruch" && exit 1;;
        esac
fi

# Wechsel in das Arbeitsverzeichnis
cd $WORKDIR

# Löschen des Deckblatts und Schreiben in ein Tages-Logfile
monapi reset reset.json 2>&1 |tee -a $WORKDIR/log/reset_$FULLDATE.log
