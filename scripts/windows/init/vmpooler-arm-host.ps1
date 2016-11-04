# Arm host for final boot
# Setup Run-Once Keys and also the immediate configuration that is needed to support
# configuring machine post vmpooler cloning

$ErrorActionPreference = 'Stop'

# Arm machine using RunOnce Keys
Write-Host "Arming machine for first-run"
reg import C:\Packer\Init\vmpooler-clone-arm-runonce.reg

# Make sure NetBios is disabled on the host to avoid netbios name collision at first boot.
# Also disable VMWare USB Arbitration service (ignore errors if it is not there)
Set-Service "lmhosts" -StartupType Disabled
Set-Service "netbt" -StartupType Disabled
Set-Service "VMUSBArbService" -StartupType Disabled  -ErrorAction SilentlyContinue

# Remove the pagefile
Write-Host "Removing page file.  Recreates on next boot"
reg.exe ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"    /v "PagingFiles" /t REG_MULTI_SZ /f /d """"

# End
