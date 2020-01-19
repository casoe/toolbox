@echo off

echo Checking problematic SVN updates
echo If there is no "KB2750841" or "KB2735855" mentioned in the next lines there is no problem :-)

wmic qfe get hotfixid | find "KB2750841"
wmic qfe | find "KB2750841"

wmic qfe get hotfixid | find "KB2735855"
wmic qfe | find "KB2735855"

pause