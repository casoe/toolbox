#!/bin/bash
# motioneye-sync.sh
# Carsten Soehrens, 17.03.2022

# set -x

# Historie
# 2022-03-17 Initiale Version
# 2022-04-14 Zeitfenster auf 3 Tage reduziert

### Synce das Output-Verzeichnis auf MotionEye ohne Thumbnails
rsync -av -e ssh --exclude '.keep'  --exclude '*.thumb' root@192.168.2.79:/data/output/Camera1/ /volume1/backup/motionseye/video/

## Entferne alle Video kleiner als 5MB UND älter als 3 Tage
rm -rvf $(find /volume1/backup/motionseye/video/ -type f -size -5M -mtime +3)

