# Continous loop script to execute Windows update.
# Once completed, cancel the scheduled task and start win-rm


$ErrorActionPreference = 'Stop'

. C:\Packer\Scripts\windows-env.ps1


$rundate = Get-Date
write-output "Script: packer-windows-update.ps1 Starting at: $rundate"

# Install latest .Net package prior to any windows updates.
Install-DotNetLatest
if (Test-PendingReboot) {
  Invoke-Reboot
}

# Run the (Optional) Installation Package File.

if (Test-Path "A:\platform-packages.ps1")
{
  & "A:\platform-packages.ps1"
}
else {
  Write-Warning "No additional packages found in $PackageDir"
}

# Run Windows Update - this will repeat as often as needed through the Invoke-Reboot cycle.
# When no more reboots are needed, the script falls through to the end.
Write-Output "Searching for Windows Updates"
if ($WindowsVersion -like $WindowsServer2016) {
  Write-Output "Disabling some more Windows Update (10) parameters"
  Write-Output "Disable seeding of updates to other computers via Group Policies"
  force-mkdir "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
  Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" 0
}

Write-Output "Using PSWindowsUpdate module"
Import-Module "$PackerStaging\PSWindowsUpdate\PSWindowsUpdate.psd1"

# Repeat this command twice to ensure any interrupted downloads are re-attempted for install.
# Windows-10 in particular seems to be affected by intermittency here - so try and improve reliability
$Attempt = 1
do {
  if (Test-Path "$PackerLogs\Mock.Platform" ) {
    Write-Output "Test Platform Build - exiting"
    break
  }
  Write-Output "Windows Update Pass $Attempt"
  try {
    # Need to handle Powershell 2 compatibility issue here - Unblock-File is used but not
    # present in PS2
    if ($psversiontable.psversion.major -eq 2) {
      Get-WUInstall -AcceptAll -UpdateType Software -IgnoreReboot -Erroraction SilentlyContinue
      Write-Output "Running PSWindows Update - Ignoring errors (PS2)"
    }
    else {
      Write-Output "Running PSWindows Update"
      Get-WUInstall -AcceptAll -UpdateType Software -IgnoreReboot
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
Write-Output "Proceeding with Shutdown"
shutdown /t 0 /r /f
