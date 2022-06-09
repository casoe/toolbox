#!/bin/bash
# Name : cron-psql-vacuum-analyze.sh
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

SCRIPT="cron-psql-vacuum-analyze.sh"
PSQL_BCS="psql postgresql://bcs@$DATABASE/bcs"
PSQL_ODS30="psql postgresql://bcs@$DATABASE/ods30"
PSQL_ODS70="psql postgresql://bcs@$DATABASE/ods70"
PSQL_ODS80="psql postgresql://bcs@$DATABASE/ods80"

START_GLOBAL=$(date +%s)
START=$(date +%s)

echo "*** STARTUP BCS: VACUUM (VERBOSE, ANALYZE);"
$PSQL_BCS << EOF
VACUUM (VERBOSE, ANALYZE);
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT had a problem in step 1/4 (BCS-DB), please check the log"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

END=$(date +%s)
echo "*** STATISTICS: Vacuum and analyze time step 1/4 (BCS-DB):" `date -u -d "0 $END seconds - $START seconds" +"%H:%M:%S"`
START=$(date +%s)

echo "*** STARTUP ODS30: VACUUM (VERBOSE, ANALYZE);"
$PSQL_ODS30 << EOF
VACUUM (VERBOSE, ANALYZE);
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT had a problem in step 2/4 (ODS30-DB), please check the log"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

END=$(date +%s)
echo "*** STATISTICS: Vacuum and analyze time step 2/4 (ODS30-DB):" `date -u -d "0 $END seconds - $START seconds" +"%H:%M:%S"`
START=$(date +%s)

echo "*** STARTUP ODS70: VACUUM (VERBOSE, ANALYZE);"
$PSQL_ODS70 << EOF
VACUUM (VERBOSE, ANALYZE);
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT had a problem in step 3/4 (ODS70-DB), please check the log"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

END=$(date +%s)
echo "*** STATISTICS: Vacuum and analyze time step 3/4 (ODS70-DB):" `date -u -d "0 $END seconds - $START seconds" +"%H:%M:%S"`
START=$(date +%s)

echo "*** STARTUP ODS80: VACUUM (VERBOSE, ANALYZE);"
$PSQL_ODS80 << EOF
VACUUM (VERBOSE, ANALYZE);
EOF

if [ $? -ne 0 ]; then
{
	echo "Error: $SCRIPT had a problem in step 4/4 (ODS80-DB), please check the log"|mail -s "BCS $SCRIPT" bcs-support@inform-software.com
	exit 1;
}
fi;

END=$(date +%s)
echo "*** STATISTICS: Vacuum and analyze time step 4/4 (ODS80-DB):" `date -u -d "0 $END seconds - $START seconds" +"%H:%M:%S"`
echo "*** STATISTICS: Vacuum and analyze time overall:" `date -u -d "0 $END seconds - $START_GLOBAL seconds" +"%H:%M:%S"`
