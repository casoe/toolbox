@echo off
netsh wlan set hostednetwork mode=allow ssid="csoehren" key="csoehren123" keyUsage=persistent
netsh wlan start hostednetwork
netsh interface ip set address name="Wireless Network Connection 2" static 192.168.1.10 255.255.255.0 192.168.1.10 1

pause