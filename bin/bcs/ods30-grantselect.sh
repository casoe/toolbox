#!/bin/bash
# Name : ods30-grantselect.sh
# Autor: Carsten Söhrens

### Überprüfe, auf welcher Maschine das Skript ausgeführt wird
### Setzen des Hosts für die Datenbank entsprechend der Verbindung
MACHINE=`uname -n`
if [[ "$MACHINE" == 'bcs' ]]; then
	DATABASE=172.16.1.103
else
	DATABASE=localhost
fi

PSQL_GB30="psql postgresql://bcs@$DATABASE/ods30"


#for table in `echo "SELECT schemaname||'.'||relname FROM pg_stat_all_tables WHERE schemaname NOT IN('pg_catalog','pg_toast','information_schema') AND relname LIKE 'bcs\_%'" | $PSQL_GB30 `;
#do
#    echo "grant select on table $table to dashboard30;"
#    #echo "grant select on table $table to my_new_user;" | psql db
#done

#exit 0

$PSQL_GB30 << EOF
GRANT SELECT ON bcs_akquisen TO dashboard30;
GRANT SELECT ON bcs_auftragsplan TO dashboard30;
GRANT SELECT ON bcs_aufwandsplan TO dashboard30;
GRANT SELECT ON bcs_buchungen TO dashboard30;
GRANT SELECT ON bcs_konferenzregistrierung TO dashboard30;
GRANT SELECT ON bcs_mitarbeiter TO dashboard30;
GRANT SELECT ON bcs_organisationen TO dashboard30;
GRANT SELECT ON bcs_projekte TO dashboard30;
GRANT SELECT ON bcs_rechnungen TO dashboard30;
GRANT SELECT ON bcs_spesen TO dashboard30;
GRANT SELECT ON bcs_stundensaetze TO dashboard30;
GRANT SELECT ON bcs_termine TO dashboard30;
GRANT SELECT ON bcs_zahlungstermine TO dashboard30;
GRANT SELECT ON datev_umsatz TO dashboard30;
GRANT SELECT ON datev_kosten TO dashboard30;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO controlling30;

SELECT table_name, grantee, privilege_type
FROM information_schema.role_table_grants
WHERE  	table_name like 'bcs_%' OR
	table_name like 'monlist_%' OR
	table_name like 'datev_%'
ORDER BY table_name, grantee, privilege_type;

EOF
