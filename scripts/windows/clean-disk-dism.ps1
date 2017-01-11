$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

$SpaceAtStart = [Math]::Round( ((Get-WmiObject win32_logicaldisk | where { $_.DeviceID -eq $env:SystemDrive }).FreeSpace)/1GB, 2)

$WindowsVersion = (Get-WmiObject win32_operatingsystem).version

#Set all CleanMgr VolumeCache keys to StateFlags = 0 to prevent cleanup. After, set the proper keys to 2 to allow cleanup.
$SubKeys = Get-Childitem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches
Foreach ($Key in $SubKeys)
{
    Set-ItemProperty -Path $Key.PSPath -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagNoAction
}

# Cleanup Windows Update area after all that
# Clean the WinSxS area - actual action depends on OS Level - full DISM commands only available from 2012R2 and later.
Write-Host "Cleaning up WinxSx updates"
if ($WindowsVersion -eq '6.1.7601') {
  # Windows 2008R2/Win-7 - just set registry keys for cleanmgr utility
  reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup"       /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
  reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Service Pack Cleanup" /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
}
ElseIf ($WindowsVersion -eq '6.2.9200') {
  # Note /ResetBase option is not available on Windows-2012, so need to screen for this.
  dism /online /Cleanup-Image /StartComponentCleanup
  dism /online /cleanup-image /SPSuperseded
} else {
  dism /online /Cleanup-Image /StartComponentCleanup /ResetBase
  dism /online /cleanup-image /SPSuperseded
}

# Set registry keys for all the other cleanup areas we want to address with cleanmgr - fairly comprehensive cleanup
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders"                    /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files"                     /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files"                         /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Memory Dump Files"                            /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files"                             /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations"                       /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin"                                  /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files"                              /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files"               /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files"                  /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files"                              /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files"                        /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files"                      /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Archive Files"        /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Queue Files"          /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Archive Files" /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Queue Files"   /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f
reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files"                    /v $CleanMgrStateFlags /t REG_DWORD /d $CleanMgrStateFlagClean /f

# Run Cleanmgr utility
Write-Host "Running CleanMgr with Sagerun:$CleanMgrSageSet"
Start-Process -Wait "cleanmgr" -ArgumentList "/sagerun:$CleanMgrSageSet"

# Now that all Update operations are complete, disable Windows Update and STOP it.
Write-Host "Stopping and Disabling Windows Update"
net stop wuauserv
Set-Service wuauserv -StartupType Disabled

# Clean up files (including those not addressed by cleanmgr)
Write-Host "Clearing Files"
@(
    "$ENV:LOCALAPPDATA\temp\*",
    "$ENV:WINDIR\logs",
    "$ENV:WINDIR\temp\*",
    "$ENV:WINDIR\SoftwareDistribution\Download\*",
    "$ENV:USERPROFILE\AppData\Local\Microsoft\Windows\WER\ReportArchive",
    "$ENV:USERPROFILE\AppData\Local\Microsoft\Windows\WER\ReportQueue",
    "$ENV:ALLUSERSPROFILE\Microsoft\Windows\WER\ReportArchive",
    "$ENV:ALLUSERSPROFILE\Microsoft\Windows\WER\ReportQueue",
    "$ENV:WINDIR\winsxs\manifestcache"
) | % {
        if(Test-Path $_) {
            Write-Host "Removing $_"
            Takeown /d Y /R /f $_
            Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
            Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
        }
    }

# Clearing Logs
Write-Host "Clearing Logs"
wevtutil clear-log Application
wevtutil clear-log Security
wevtutil clear-log Setup
wevtutil clear-log System

# Display Free Space Statistics at end
$SpaceAtEnd = [Math]::Round( ((Get-WmiObject win32_logicaldisk | where { $_.DeviceID -eq $env:SystemDrive }).FreeSpace)/1GB, 2)
$SpaceReclaimed = $SpaceAtEnd - $SpaceAtStart

Write-Host "Cleaning Complete"
Write-Host "Starting Free Space $SpaceAtStart GB"
Write-Host "Current Free Space $SpaceAtEnd GB"
Write-Host "Reclaimed $SpaceReclaimed GB"

# Sleep to let console log catch up (and get captured by packer)
Start-Sleep -Seconds 20
