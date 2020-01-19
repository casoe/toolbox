#!/bin/bash
# Name : bcs-backup.sh
# Autor: Carsten Söhrens

### Variablen setzen
MACHINE=`uname -n`
FULLDATE=`date +\%Y-\%m-\%d`
BACKUP=/opt/projektron/bcs/backup/${MACHINE}_backup_${FULLDATE}.zip
LOG=/opt/projektron/bcs/backup/${MACHINE}_backup_${FULLDATE}.log

### Test, ob Parameter übergeben wurde (bis zu drei)
if [ $1 ] ; then
  	OPTIONS=$1
	if [ $2 ] ; then
		OPTIONS="$OPTIONS $2"
		if [ $3 ] ; then
			OPTIONS="$OPTIONS $3"
		fi
	fi
	echo "Zusätzliche Option(en) erkannt: $OPTIONS"
else
	echo "Backup mit den Standard-Optionen"
fi

### Lösche altes Backup und Log-Datei
rm -f $BACKUP
rm -f $LOG

### Erstelle Backup und schreibe Log in Datei
echo Backup in $BACKUP
START=$(date +%s)
/opt/projektron/bcs/server/bin/Backup.sh $OPTIONS -mf 4000000000 -force -o $BACKUP |tee -a $LOG
END=$(date +%s)

### Wenn Live-System, dann kopiere auf das Test-System für einen anschließenden Restore Kopiere auf das Test-System für einen anschließenden Restore
if [[ "$MACHINE" == 'bcs' ]]; then
	echo Transfer file to bcs-test restore directory
	scp $BACKUP root@bcs-test:/opt/projektron/bcs/restore/
	echo ...Fertig
fi

### Backup-Zeit ausgeben
echo Backup time: `date -u -d "0 $END seconds - $START seconds" +"%H:%M:%S"`
