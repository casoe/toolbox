#!/bin/bash
# my_dropbox.sh
# Carsten Söhrens, 26.12.2019

# set -x

DROPBOX="$HOME/bin/dropbox_uploader.sh"

if [ ! -f "$DROPBOX" ] ; then
	curl "https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh" -o $DROPBOX
	chmod +x $DROPBOX
fi

FILE=$1
DEST="/Backup/fhem/fhem-matthias/"

#echo Uploading $FILE to $DEST
$DROPBOX upload $FILE $DEST
