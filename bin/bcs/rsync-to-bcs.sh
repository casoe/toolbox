#!/bin/bash
# Name : rsync_bcs.sh
# Autor: Carsten Söhrens

rsync -avP --delete --exclude '*.beta.zip' /opt/projektron/bcs/updates/ root@172.16.1.101:/opt/projektron/bcs/updates
