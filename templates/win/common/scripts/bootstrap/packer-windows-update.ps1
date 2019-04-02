# Continous loop script to execute Windows update.
# Once completed, cancel the scheduled task and start win-rm


$ErrorActionPreference = 'Stop'

. C:\Packer\Scripts\windows-env.ps1


$rundate = Get-Date
write-output "Script: packer-windows-update.ps1 Starting at: $rundate"

# Need to guard against system going into standby for long updates
Write-Output "Disabling Sleep timers"
Disable-PC-Sleep

# Install latest .Net package prior to any windows updates - this NOT done for:
# Powershell 2.0 builds (win-2008, win-2008R2 and Win-7)
# Windows 10/2016 - this comes with either the latest, or close to latest.
if ( ($WindowsVersion -Like $WindowsServer2016) -or (($PSVersionTable.PSVersion.Major) -eq 2) ) {
  Write-Output "Skipping .Net Installation/Checks"
} else {
  Install-DotNetLatest
  if (Test-PendingReboot) {
    Invoke-Reboot
  }
}

# Run the (Optional) Installation Package File 
# 

if (Test-Path "A:\platform-packages.ps1" )
{
  & "A:\platform-packages.ps1"
}

Import-PsWindowsUpdateModule

# Run Windows Update - this will repeat as often as needed through the Invoke-Reboot cycle.
# When no more reboots are needed, the script falls through to the end.
# Repeat this command twice to ensure any interrupted downloads are re-attempted for install.
# Windows-10 in particular seems to be affected by intermittency here - so try and improve reliability
Write-Output "Searching for Windows Updates"

$Attempt = 1
do {
  if (Test-Path "$PackerLogs\Mock.Platform" ) {
    Write-Output "Test Platform Build - exiting"
    break
  }
  Write-Output "Windows Update Pass $Attempt"

  try {
    # The format and command for windows update differs across windows versions.
    # See below.
    If ($WindowsVersion -like $WindowsServer2016) {
      # Use Latest (2.1.1.2) for Win-10/2016 only
      # Note 'KB2267602' is screened out as it doesn't appear to install correctly.
      Write-Output "Running PSWindows Update"
      Install-WindowsUpdate -AcceptAll -UpdateType Software -IgnoreReboot -NotKBArticleID 'KB2267602'
    } elseif ($psversiontable.psversion.major -eq 2) {
      # Ignore errors on PS2 (in case of unblock file errors)
      Write-Output "Running PSWindows Update - Ignoring errors (PS2)"
      Get-WUInstall -AcceptAll -UpdateType Software -IgnoreReboot -Erroraction SilentlyContinue
    } else {
      # All other versions - mainly 2012r2 use this version
      Write-Output "Running PSWindows Update - Non Verbose Mode"
      Install-WindowsUpdate -AcceptAll -UpdateType Software -IgnoreReboot
    }
    if (Test-PendingReboot) { 
      Invoke-Reboot 
    }
  }
  catch {
    Write-Warning "ERROR updating Windows"
    # Code here to trap error and fall out of process dumping log.
  }
  $Attempt++
} while ($Attempt -le 2)

# Run the Application Package Cleaner
if (Test-Path "$PackerLogs\AppsPackageRemove.Required") {
  Write-Output "Running Apps Package Cleaner post windows update"
  Remove-AppsPackages -AppPackageCheckpoint AppsPackageRemove.Pass1
}

# Windows Update Cycle complete - delete this task.
Write-Output "Deleting Bootstrap Scheduled Task"
schtasks /Delete /tn PackerWinUpdate /F

# Enable WinRM so Packer control will resume after reboot.
Set-Service "WinRM" -StartupType Automatic
Write-Output "WinRM Enabled - Packer will resume next reboot"

# Restart computer using shutdown command (PS2/3 compatibility)
$shutdate = Get-Date
Write-Output "Proceeding with Shutdown at: $shutdate"
shutdown /t 0 /r /f
Start-Sleep -Seconds 10
Exit 0
