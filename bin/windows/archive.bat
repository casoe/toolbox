@echo off

echo ### Setting variables...
@For /F "tokens=1,2,3 delims=. " %%A in ('Date /t') do @(
  set day=%%A
  set month=%%B
  set year=%%C
  )
set timestamp=%year%-%month%-%day%
set folder=d:\01 working\_Umsatzplanung\archive 2013
set backupcmd=xcopy /f /y /c
set source=Umsatzplanung CSo.xls
set target=Umsatzplanung CSo %timestamp%.xls

echo ### Backing up the file...
del "%folder%\%target%"
%backupcmd% "%source%" "%folder%"
ren "%folder%\%source%" "%target%"

echo Backup Complete!

rem @ping 127.0.0.1 -n 5 -w 100 > nul
