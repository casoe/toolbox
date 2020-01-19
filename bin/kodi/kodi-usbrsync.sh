#!/bin/bash

function somethingMounted {
        mountpoint="$1"
        if ! device1=$(stat -c "%d" $mountpoint); then
                echo "Error on stat of mount point, maybe file doesn't exist?" 1>&2
                return 1
        fi
        if ! device2=$(stat -c "%d" $mountpoint/..); then
                echo "Error on stat one level up from mount point, maybe file doesn't exist?" 1>&2
                return 1
        fi

        if [[ $device1 -ne $device2 ]]; then
                #echo "Somethin mounted there I reckon"
                return 0
        else
                #echo "Nothin mounted it seems"
                return 1
        fi
}

if somethingMounted /media/shares/usb64gb; then
        flock -xn /home/pi/rsync.lck -c 'rsync -avhW --no-compress /media/shares/usb64gb/Movies/* /media/shares/hd2tb/temp/'
fi

