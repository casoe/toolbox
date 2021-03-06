@echo off

set MYFILENAME=%~n1
set MYEXTENSION=%~x1

set MYYEAR=%MYFILENAME:~0,4%
echo %MYYEAR%
set MYMONTH=%MYFILENAME:~5,2%
echo %MYMONTH%
set MYDAY=%MYFILENAME:~8,2%
echo %MYDAY%

set MYHOUR=%MYFILENAME:~11,2%
echo %MYHOUR%
set MYMIN=%MYFILENAME:~14,2%
echo %MYMIN%
set MYSEC=%MYFILENAME:~17,2%
echo %MYSEC%

filetouch /W /A /C /D %MYMONTH%-%MYDAY%-%MYYEAR% /T %MYHOUR%:%MYMIN%:%MYSEC% %1
