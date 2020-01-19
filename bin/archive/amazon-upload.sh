#!/bin/bash

TODAY=`date +"%Y-%m-%d"`
LOCK="/home/osmc/amazon-upload.lck"
LOG="/home/osmc/log/amazon-upload_$TODAY.log"
ACDCLI="/usr/local/bin/acd_cli"
SOURCE="/mnt/hd2tb/photos"

case "$1" in
  start)
    ### Start Code
    if [[ -e "${LOCK}" ]]; then
      rm $LOCK
    fi

    date > $LOG
    $ACDCLI sync >> $LOG

    for DIRECTORY in $SOURCE/*; do
      if [[ -e "${LOCK}" ]]; then
        date >> $LOG
        echo "Stop initiated" >> $LOG
        rm $LOCK
        exit 1
      fi
      if [[ -d $DIRECTORY ]]; then
        echo Uploading "$DIRECTORY" >> $LOG
        $ACDCLI upload -d -x 4 -xe mp4 -xe mov "$DIRECTORY" /
        date >> $LOG
      fi
    done
    ;;

  stop)
    ### Stop Code
    touch $LOCK
    killall -9 acd_cli
    ;;

  *)
    echo "Usage: $0 {start|stop}" >&2
    exit 1
    ;;
esac
