#!/bin/bash
# Name : ods80-statistics.sh
# Autor: Carsten Söhrens

### Überprüfe, auf welcher Maschine das Skript ausgeführt wird
### Setzen des Hosts für die Datenbank entsprechend der Verbindung
MACHINE=`uname -n`
if [[ "$MACHINE" == 'bcs' ]]; then
	DATABASE=172.16.1.103
else
	DATABASE=localhost
fi

PSQL="psql postgresql://bcs@$DATABASE/ods80"

$PSQL << EOF
SELECT
  nspname AS schemaname,relname,reltuples
FROM pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE
  nspname NOT IN ('pg_catalog', 'information_schema') AND
  relkind='r'
ORDER BY relname ASC;
EOF
