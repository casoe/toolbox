#!/bin/bash
# my_dropbox.sh
# Carsten Soehrens, 26.12.2019

# set -x

DROPBOX="$HOME/bin/dropbox_uploader.sh"

# Check, ob dropbox_uploader.sh vorhanden ist; wenn nicht, dann herunterladen; anschließend startet die Konfiguration
if [ ! -f "$DROPBOX" ] ; then
	curl "https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh" -o $DROPBOX
	chmod +x $DROPBOX
fi

FILE=$1
HOSTNAME=`hostname`
DEST="/Backup/linux/$HOSTNAME"

# Check, ob schon ein Verzeichnis mit dem Hostname vorhanden ist; wenn nicht, dann eins anlegen
if [ ! $($DROPBOX list /Backup/linux |grep -o $HOSTNAME) ]
then 
	$DROPBOX mkdir $DEST
else
	echo Found directory for $HOSTNAME
fi

#echo Uploading $FILE to $DEST
$DROPBOX upload $FILE $DEST
