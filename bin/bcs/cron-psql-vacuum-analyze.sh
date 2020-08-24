#!/bin/bash
# Name : daily-psql-vacuum-analyze.sh
# Autor: Carsten Söhrens

### Auszug Postgres Dokumentation
# We recommend that active production databases be vacuumed frequently (at least nightly), 
# in order to remove dead rows. After adding or deleting a large number of rows, it might 
# be a good idea to issue a VACUUM ANALYZE command for the affected table. This will update
# the system catalogs with the results of all recent changes, and allow the PostgreSQL query 
# planner to make better choices in planning queries.

### Überprüfe, auf welcher Maschine das Skript ausgeführt wird
### Setzen des Hosts für die Datenbank entsprechend der Verbindung
MACHINE=`uname -n`
if [[ "$MACHINE" == 'bcs' ]]; then
	DATABASE=172.16.1.103
else
	DATABASE=localhost
fi

SCRIPT="daily-psql-vacuum-analyze.sh"
PSQL_BCS="psql postgresql://bcs@$DATABASE/bcs"
PSQL_ODS30="psql postgresql://bcs@$DATABASE/ods30"
PSQL_ODS70="psql postgresql://bcs@$DATABASE/ods70"
PSQL_ODS80="psql postgresql://bcs@$DATABASE/ods80"

START=$(date +%s)

echo "BCS: VACUUM (VERBOSE, ANALYZE);"
$PSQL_BCS << EOF
VACUUM (VERBOSE, ANALYZE);
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT had a problem, please check the log"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

echo "ODS30: VACUUM (VERBOSE, ANALYZE);"
$PSQL_ODS30 << EOF
VACUUM (VERBOSE, ANALYZE);
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT had a problem, please check the log"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

echo "ODS70: VACUUM (VERBOSE, ANALYZE);"
$PSQL_ODS70 << EOF
VACUUM (VERBOSE, ANALYZE);
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT had a problem, please check the log"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

echo "ODS80: VACUUM (VERBOSE, ANALYZE);"
$PSQL_ODS80 << EOF
VACUUM (VERBOSE, ANALYZE);
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT had a problem, please check the log"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

END=$(date +%s)

echo ...Fertig
echo Vacuum and analyze time: `date -u -d "0 $END seconds - $START seconds" +"%H:%M:%S"`
