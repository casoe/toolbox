#!/bin/bash
# Name  : rsync-from-bcstest.sh
# Autor : Carsten Söhrens
rsync -avP --delete --exclude 'rsync*' --exclude '*.beta.zip' root@172.16.1.102:/opt/projektron/bcs/updates/ /opt/projektron/bcs/updates
rsync -avP --delete root@172.16.1.102:/opt/projektron/bcs/restore/ /opt/projektron/bcs/restore
