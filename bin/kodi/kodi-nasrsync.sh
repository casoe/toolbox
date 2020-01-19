#!/bin/bash
# my_nasrsync.sh
# Carsten Soehrens, 04.01.2020

# set -x

# Historie
# 2020-01-07 Stoppen der Zeit ergänzt

RSYNC="/usr/bin/rsync"

# Startzeit speichern
START=$(date +%s)

# Video-Ordner
if [ ! $(mount | grep -o /mnt/persephone/video ) ]; then
    mount /mnt/persephone/video
fi
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /mnt/persephone/video/movies/*        /media/7ea28222-bdd1-44d2-b6ec-dfc9b130a0d4/movies/
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /mnt/persephone/video/kinder_filme/*  /media/7ea28222-bdd1-44d2-b6ec-dfc9b130a0d4/kinder_filme/
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /mnt/persephone/video/kinder_serien/* /media/7ea28222-bdd1-44d2-b6ec-dfc9b130a0d4/kinder_serien/
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /mnt/persephone/video/series/*        /media/7ea28222-bdd1-44d2-b6ec-dfc9b130a0d4/series/
umount /mnt/persephone/video

# Musik-Ordner
if [ ! $(mount | grep -o /mnt/persephone/music ) ]; then
    mount /mnt/persephone/music
fi
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /mnt/persephone/music/*               /media/7ea28222-bdd1-44d2-b6ec-dfc9b130a0d4/music/
umount /mnt/persephone/music/

# Foto-Ordner
if [ ! $(mount | grep -o /mnt/persephone/photo ) ]; then
    mount /mnt/persephone/photo
fi
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /mnt/persephone/photo/*               /media/7ea28222-bdd1-44d2-b6ec-dfc9b130a0d4/photos/
umount /mnt/persephone/music/

### Backup-Zeit ausgeben
echo Backup time: `date -u -d "0 $(date +%s) seconds - $START seconds" +"%H:%M:%S"`