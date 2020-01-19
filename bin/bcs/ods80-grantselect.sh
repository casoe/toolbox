#!/bin/bash
# Name : ods80-grantselect.sh
# Autor: Carsten Söhrens

### Überprüfe, auf welcher Maschine das Skript ausgeführt wird
### Setzen des Hosts für die Datenbank entsprechend der Verbindung
MACHINE=`uname -n`
if [[ "$MACHINE" == 'bcs' ]]; then
	DATABASE=172.16.1.103
else
	DATABASE=localhost
fi

PSQL_GB80="psql postgresql://bcs@$DATABASE/ods80"


#for table in `echo "SELECT schemaname||'.'||relname FROM pg_stat_all_tables WHERE schemaname NOT IN('pg_catalog','pg_toast','information_schema') AND relname LIKE 'bcs\_%'" | $PSQL_GB80 `;
#do
#    echo "grant select on table $table to dashboard80;"
#    #echo "grant select on table $table to my_new_user;" | psql db
#done

#exit 0

$PSQL_GB80 << EOF
GRANT SELECT ON bcs_buchungen TO dashboard80;
GRANT SELECT ON bcs_mitarbeiter TO dashboard80;
GRANT SELECT ON bcs_spesen TO dashboard80;
GRANT SELECT ON bcs_termine TO dashboard80;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO controlling80;

SELECT table_name, grantee, privilege_type
FROM information_schema.role_table_grants
WHERE  	table_name like 'bcs_%' OR
	table_name like 'monlist_%' OR
	table_name like 'datev_%'
ORDER BY table_name, grantee, privilege_type;

EOF
