#!/bin/bash
# Name : bcs-ldapimport.sh
# Autor: Carsten Söhrens

### set timestamp
TIMESTAMP=`date +\%m\%d-\%H\%M\%S`

/opt/projektron/bcs/server/bin/LDAPImport.sh |tee -a /opt/projektron/bcs/server/log/ldap-import_${TIMESTAMP}.log
