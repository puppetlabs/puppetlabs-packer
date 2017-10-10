# Cleanup tasks to ready this machine for production.

$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

$SpaceAtStart = [Math]::Round( ((Get-WmiObject win32_logicaldisk | where { $_.DeviceID -eq $env:SystemDrive }).FreeSpace)/1GB, 2)

Write-Output "Uninstalling Puppet Agent..."
Start-Process -Wait "msiexec" -ArgumentList "/x $PackerDownloads\puppet-agent.msi /qn /norestart"

# Clear Puppet Event Log & SOFTWARE registry keys
reg.exe delete "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Application\Puppet"  /f
reg.exe delete "HKLM\SOFTWARE\Puppet Labs" /f

# Run Cleanmgr again.
If ($WindowsVersion -like $WindowsServer2008) {
  Write-Output "Skipping CleanMgr for Windows 2008"
}
ElseIf ( $WindowsServerCore ) {
  Write-Output "Skipping Clean-Mgr as GUI not installed (Core Installation)."
}
else {
  Write-Output "Running CleanMgr with Sagerun:$CleanMgrSageSet"
  Start-Process -Wait "cleanmgr" -ArgumentList "/sagerun:$CleanMgrSageSet"
}

# Clean up files (including those not addressed by cleanmgr)
# This list is a bit different from that in the dism cleanup script.
Write-Output "Clearing Files"
@(
    "$ENV:LOCALAPPDATA\Nuget",
    "$ENV:LOCALAPPDATA\temp\*",
    "$ENV:WINDIR\logs",
    "$ENV:WINDIR\temp\*",
    "$ENV:USERPROFILE\AppData\Local\Microsoft\Windows\WER\ReportArchive",
    "$ENV:USERPROFILE\AppData\Local\Microsoft\Windows\WER\ReportQueue",
    "$ENV:ALLUSERSPROFILE\Microsoft\Windows\WER\ReportArchive",
    "$ENV:ALLUSERSPROFILE\Microsoft\Windows\WER\ReportQueue",
    "$ENV:WINDIR\winsxs\manifestcache",
    "C:\ProgramData\PuppetLabs",
    "C:\Program Files\Puppet Labs"
) | % { ForceFullyDelete-Paths "$_" }

# Clearing Logs
Write-Output "Clearing Logs"
wevtutil clear-log Application
wevtutil clear-log Security
wevtutil clear-log Setup
wevtutil clear-log System

# Display Free Space Statistics at end
$SpaceAtEnd = [Math]::Round( ((Get-WmiObject win32_logicaldisk | where { $_.DeviceID -eq $env:SystemDrive }).FreeSpace)/1GB, 2)
$SpaceReclaimed = $SpaceAtEnd - $SpaceAtStart

Write-Output "Cleaning Complete"
Write-Output "Starting Free Space $SpaceAtStart GB"
Write-Output "Current Free Space $SpaceAtEnd GB"
Write-Output "Reclaimed $SpaceReclaimed GB"

# Remove the pagefile
Write-Output "Removing page file.  Recreates on next boot"
reg.exe ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"    /v "PagingFiles" /t REG_MULTI_SZ /f /d """"

# Sleep to let console log catch up (and get captured by packer)
Start-Sleep -Seconds 20
#End
