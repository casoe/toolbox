@echo off

:: robocopy backup script
:: by Carsten Soehrens
:: 28.12.2010


:: setting variables

@For /F "tokens=1,2,3 delims=. " %%A in ('Date /t') do @(
  set day=%%A
  set month=%%B
  set year=%%C
  )
set timestamp=%year%-%month%-%day%

set robocopy="c:\Programme\Windows Resource Kits\Tools\robocopy.exe"
set logfile=c:\Scripts\log\robocopy_%timestamp%.log
:: set options=/E /Z /MIR /R:1 /TEE /COPY:D /V /XN /XO /LOG+:%logfile%
set options=/E /Z /MIR /R:1 /XN /XO /LOG+:%logfile%

:: options
:: /E      copy empty directories
:: /Z      copy in restartable mode (if connection is lost transfer can proceed where it stopped)
:: /MIR    mirror (delete files on the right if not anymore on the left)
:: /R:1    try one restart if first try doesn't work
:: /TEE    log to file and to console
:: /COPY:D copy only data (no timestamps, owner information, etc.)
:: /V      be verbose about progress
:: /XO     don't copy of the file is older than in the source
:: /XN     don't copy of the file is newer than in the source
:: (if XO and XN are not uses most of the files are copied again, maybe due to NTFS/EXT3 differences)
:: LOG+    append output to logfile

:: delete old logfile from the same day
del %logfile%

:: starting robocopy jobs

echo Starting \\Demeter\Musik
%robocopy% \\Demeter\Musik  \\hermes\mp3    %options%

echo Starting \\Demeter\Fotos
%robocopy% \\Demeter\Fotos  \\hermes\fotos  %options%

echo Starting \\Demeter\Software
%robocopy% \\Demeter\Software         \\hermes\backup\Software %options%

echo Starting \\Demeter\Benutzer\Carsten
%robocopy% \\Demeter\Benutzer\Carsten \\hermes\backup\Carsten  %options%

echo Starting \\Demeter\Benutzer\Tina
%robocopy% \\Demeter\Benutzer\Tina    \\hermes\backup\Tina     %options%

