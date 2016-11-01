$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

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
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup"       -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Service Pack Cleanup" -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
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
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders"                    -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files"                     -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files"                         -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Memory Dump Files"                            -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files"                             -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations"                       -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin"                                  -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files"                              -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files"               -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files"                  -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files"                              -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files"                        -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files"                      -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Archive Files"        -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Queue Files"          -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Archive Files" -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Queue Files"   -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files"                    -Name $CleanMgrStateFlags -Value $CleanMgrStateFlagClean

# Run Cleanmgr utility
Write-Host "Running CleanMgr with Sagerun:$CleanMgrSageSet"
Start-Process -Wait "cleanmgr" -ArgumentList "/sagerun:$CleanMgrSageSet"
