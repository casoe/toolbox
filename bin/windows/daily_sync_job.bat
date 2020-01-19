@ECHO OFF
rem taken copy of network files onto desktop
rem 08.12.2006 WV 
rem 22.11.2007 CSo
rem 12.08.2008 CSo (/D option entfernt)
rem 15.11.2010 Pfad korrigiert ("&" gegen "und" getauscht)
rem 31.03.2011 Anpassung für Windows 7 und Korrektur von Dateinamen/Pfaden
rem 20.06.2011 Pfade angepasst
rem 19.10.2011 RTCBranches hinzugefügt
rem 21.10.2011 Umstellung xlsx berücksichtigt
rem 18.06.2012 Pfade an Orderrestrukturierung angepasst
rem 20.11.2012 Pfade bei Dropbox angepasst
rem 10.04.2013 Pfade bei Dropbox angepasst
rem 26.08.2013 Umsatzplanung entfernt
rem 25.03.2014 Zusammenfassung alle täglichen Syncjobs in einem Skript
rem 27.03.2014 Größenangabe git-Archiv für Evernote ergänzt


echo ******************************************************************************
echo *                  local or internet/intranet jobs                           *
echo ******************************************************************************

echo .
echo Evernote git commit...
c:
cd "C:\Users\csoehren\AppData\Local\Evernote\Evernote\Databases"
git commit -am "Automatic daily commit"
git gc
du -sm .git


echo .
echo SVN update BIS repository...
d:
cd "d:\11 groundstar\BIS\"
svn update

echo .
echo SVN update BIS-DEV repository...
d:
cd "d:\11 groundstar\BIS-DEV\"
svn update



echo .
echo SyncJob...
cd "C:\Program Files (x86)\SyncJobCalendar"
"C:\Program Files (x86)\SyncJobCalendar\syncjobcalendar.exe" -gwu=csoehren -gws=gwserver -gwc=Calendar -gwm=false -gdu=soehrens@gmail.com -gdc=INFORM -gdi=true




echo ******************************************************************************
echo *                  checking novell network availability                      *
echo ******************************************************************************

if exist "J:\Plan\Fachberater und KPM\Fachberater Tagesplan.xlsx" goto LAN

echo .
echo No LAN available, exiting .....
echo .

goto END

echo ******************************************************************************
echo *                              copying files                                 *
echo ******************************************************************************


:LAN 
echo .
echo LAN Available
echo Copy selected files to local drive...
echo .

xcopy /F /Y /C "J:\Plan\Fachberater und KPM\Fachberater Tagesplan.xlsx" "D:\21 my data\Documents\My Dropbox\carsten.soehrens@inform-ac.com\Dropbox\Tray"
xcopy /F /Y /C "J:\Plan\Fachberater und KPM\Fachberater Tagesplan.xlsx" "D:\20 shortcuts"
xcopy /F /Y /C "N:\Kurzwahlen\Kurzwahlen.xls"                           "D:\20 shortcuts"
xcopy /F /Y /C "N:\Monlist2\projekte.txt"                               "D:\20 shortcuts"
xcopy /F /Y /C "J:\EntwicklerNews\RealTime\RTCBranches.xls"             "D:\20 shortcuts"


echo .
echo SyncToy...
"C:\Program Files\SyncToy 2.1\SyncToyCmd.exe" -R >> sync.log
echo .


:END
echo .
echo ******************************************************************************
echo *                                  finish                                    *
echo ******************************************************************************
rem pause -1

rem eof

