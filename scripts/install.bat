rem set winrm to enable bootstrapping
winrm quickconfig -q
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in
localport=5985 action=allow
netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allownet stop winrm
sc config winrm start=auto
net start winrm
rem install chocolatey
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
C:\ProgramData\chocolatey\bin\choco.exe install chefdk -y
C:\ProgramData\chocolatey\bin\choco.exe install chef-client -y
C:\ProgramData\chocolatey\bin\choco.exe install git -y
C:\ProgramData\chocolatey\bin\choco.exe install googlechrome -y
C:\ProgramData\chocolatey\bin\choco.exe install visualstudiocode -y
chef gem install kitchen-azurerm -y
