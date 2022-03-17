#!/bin/bash
# usb-sync.sh
# Carsten Soehrens, 18.01.2022

# set -x

# Historie
# 18.01.2022 Initiale Version

RSYNC="/bin/rsync"

$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /volume1/video/kinder_filme  /volumeUSB1/usbshare/
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /volume1/video/kinder_serien /volumeUSB1/usbshare/
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /volume1/video/movies        /volumeUSB1/usbshare/
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /volume1/video/series        /volumeUSB1/usbshare/
