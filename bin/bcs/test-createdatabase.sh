#!/bin/bash -x
# Name : test-createdatabase.sh
# Autor: Carsten Söhrens

### Setting variables
MACHINE=`uname -n`
BCSHOME="/opt/projektron/bcs/server"

### Check if it's the test server, otherwise abort
if [[ "$MACHINE" == 'bcs' ]]; then
	echo "This is the live server. Abort!" && exit 1
fi

#su postgres -c 'dropdb --if-exists ods30'
#su postgres -c 'dropdb --if-exists ods70'
#su postgres -c 'dropdb --if-exists ods80'

su postgres -c 'createuser -P --interactive --no-createdb --no-createrole --no-superuser bcs'
su postgres -c 'createuser -P --interactive --no-createdb --no-createrole --no-superuser dashboard30'
su postgres -c 'createuser -P --interactive --no-createdb --no-createrole --no-superuser dashboard70'
su postgres -c 'createuser -P --interactive --no-createdb --no-createrole --no-superuser dashboard80'
su postgres -c 'createuser -P --interactive --no-createdb --no-createrole --no-superuser controlling30'
su postgres -c 'createuser -P --interactive --no-createdb --no-createrole --no-superuser controlling70'
su postgres -c 'createuser -P --interactive --no-createdb --no-createrole --no-superuser controlling80'

su postgres -c 'createdb -E UTF8 -O bcs bcs'
su postgres -c 'createdb -E UTF8 -O bcs ods30'
su postgres -c 'createdb -E UTF8 -O bcs ods70'
su postgres -c 'createdb -E UTF8 -O bcs ods80'
