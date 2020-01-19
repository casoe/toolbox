sudo mount -t cifs -o credentials=~/.cifs //morpheus/shares/other/backup /mnt/backup
sudo raspiBackup.sh -a : -o : -m detailed
sudo umount /mnt/backup
