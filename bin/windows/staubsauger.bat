@echo off

del /s /q /f "%TEMP%\*"
del /s /q /f "%USERPROFILE%\Recent\*"
del /s /q /f "%USERPROFILE%\Cookies\*"
del /s /q /f "%USERPROFILE%\Local Settings\History\*"
del /s /q /f "%USERPROFILE%\Local Settings\Temp\*.*"
del /s /q /f "%USERPROFILE%\Local Settings\Temporary Internet Files\*.*"
del /s /q /f "%windir%\Temp\*.*"
del /s /q /f "%windir%\Temporary Internet Files\*.*"

del /s /q /f "C:\oracle\admin\cas10g\bdump\*.*"
del /s /q /f "C:\oracle\admin\cas10g\udump\*.*"

rem pause
