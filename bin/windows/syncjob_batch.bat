echo SyncJob...
cd "C:\Program Files (x86)\SyncJobCalendar"
"C:\Program Files (x86)\SyncJobCalendar\syncjobcalendar.exe" -gwu=csoehren -gws=gwserver -gwc=Calendar -gwm=false -gdu=soehrens@gmail.com -gdc=INFORM -gdi=true

@ping 127.0.0.1 -n 5 -w 100 > nul