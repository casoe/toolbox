#!/bin/bash
# Name : fixpermissions.sh
# Autor: Carsten Söhrens

#cd /media/b281c1af-163d-443f-a0e7-c75c08984096/
cd /mnt/hd2tb

for FOLDER in home_videos movies music photos series
do

  find $FOLDER -type d -exec chmod 755 {} \;; find $FOLDER -type f -exec chmod 644 {} \;
  chown osmc.osmc $FOLDER -R

done
