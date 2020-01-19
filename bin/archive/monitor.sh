#!/bin/bash
# load + temp
echo -n "$( uptime ) "
vcgencmd measure_temp
sudo hdparm -C /dev/sda
