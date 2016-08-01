# Arm host for final boot
# Setup Run-Once Keys and also the immediate configuration that is needed to support
# configuring machine post vmpooler cloning

$ErrorActionPreference = 'Stop'

# Arm machine using RunOnce Keys
Write-Host "Arming machine for first-run"
reg import C:\Packer\Init\vmpooler-clone-arm.reg

# Make sure NetBios is disabled on the host to avoid netbios name collision at first boot.
# Also disable VMWare USB Arbitration service (ignore errors if it is not there)
Set-Service "lmhosts" -StartupType Disabled
Set-Service "netbt" -StartupType Disabled
Set-Service "VMUSBArbService" -StartupType Disabled  -ErrorAction SilentlyContinue

# Re-Enable AutoAdminLogon
$WinlogonPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $WinlogonPath -Name AutoAdminLogon -Value "1" -ErrorAction SilentlyContinue
Set-ItemProperty -Path $WinlogonPath -Name DefaultUserName -Value "Administrator" -ErrorAction SilentlyContinue
Set-ItemProperty -Path $WinlogonPath -Name DefaultPassword -Value "PackerAdmin" -ErrorAction SilentlyContinue

# End
