#!/bin/bash
# kodi-nasrsync.sh
# Carsten Soehrens, 04.01.2020

# set -x

# Historie
# 07.02.2020 Stoppen der Zeit ergänzt
# 31.05.2020 Logging auf Variante mit Funktion umgestellt

RSYNC="/usr/bin/rsync"
LOG="/home/osmc/log/kodi-nasrsync.log"

### Funktion zum effizienteren Logging
log() {
	if [[ -z "$LOG" ]]; then
			echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: ERROR log variable in $0 not defined" 1>&2
			exit 1
	fi

	echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: $*" >> $LOG 2>&1
}

### Log öffnen und Startzeit speichern
log "INFO" "Start von $0"
START=$(date +%s)

### Video-Ordner mounten und synchronisieren
log "INFO" "Video-Ordner mounten und synchronisieren"
if [ ! $(mount | grep -o /mnt/persephone/video ) ]; then
    mount /mnt/persephone/video
fi
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /mnt/persephone/video/movies/*        /media/7ea28222-bdd1-44d2-b6ec-dfc9b130a0d4/movies/
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /mnt/persephone/video/kinder_filme/*  /media/7ea28222-bdd1-44d2-b6ec-dfc9b130a0d4/kinder_filme/
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /mnt/persephone/video/kinder_serien/* /media/7ea28222-bdd1-44d2-b6ec-dfc9b130a0d4/kinder_serien/
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /mnt/persephone/video/series/*        /media/7ea28222-bdd1-44d2-b6ec-dfc9b130a0d4/series/
umount /mnt/persephone/video

### Musik-Ordner mounten und synchronisieren
log "INFO" "Musik-Ordner mounten und synchronisieren"
if [ ! $(mount | grep -o /mnt/persephone/music ) ]; then
    mount /mnt/persephone/music
fi
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /mnt/persephone/music/*               /media/7ea28222-bdd1-44d2-b6ec-dfc9b130a0d4/music/
umount /mnt/persephone/music/

### Foto-Ordner mounten und synchronisieren
log "INFO" "Foto-Ordner mounten und synchronisieren"
if [ ! $(mount | grep -o /mnt/persephone/photo ) ]; then
    mount /mnt/persephone/photo
fi
$RSYNC -avhW --no-compress --exclude '@eaDir' --delete /mnt/persephone/photo/*               /media/7ea28222-bdd1-44d2-b6ec-dfc9b130a0d4/photos/
umount /mnt/persephone/photo/

### Backup-Zeit ausgeben
log "INFO" "Backup-Zeit ausgeben"
echo Backup time: `date -u -d "0 $(date +%s) seconds - $START seconds" +"%H:%M:%S"`
