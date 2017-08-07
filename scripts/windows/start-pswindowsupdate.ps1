$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1
$PackageDir = 'A:\'

# Create Packer Log Directories if they don't exist already.
Create-PackerStagingDirectories

# Record sessions in transcript
Start-Transcript -Append -IncludeInvocationHeader -Path "$PackerLogs\start-pswindowsupdate.log"

# Install latest .Net package prior to any windows updates.
Install-DotNetLatest

if (-not (Test-Path "$PackerLogs\7zip.installed")) {
  # Download and install 7za now as its needed here and is useful going forward.
  Write-Host "Installing 7zip"
  Download-File http://buildsources.delivery.puppetlabs.net/windows/7zip/7z1602-$ARCH.exe  $Env:TEMP\7z1602-$ARCH.exe
  Start-Process -Wait "$Env:TEMP\7z1602-$ARCH.exe" @SprocParms -ArgumentList "/S"
  Touch-File "$PackerLogs\7zip.installed"
  Write-Host "7zip Installed"
}

if (-not (Test-Path "$PackerLogs\PSWindowsUpdate.installed")) {
  # Download and install PSWindows Update Modules.
  Download-File "http://buildsources.delivery.puppetlabs.net/windows/pswindowsupdate/PSWindowsUpdate.zip" "$Env:TEMP/pswindowsupdate.zip"
  # TBD - Add te Temp Directory instead so it can be removed.
  $zproc = Start-Process "$7zip" @SprocParms -ArgumentList "x $Env:TEMP/pswindowsupdate.zip -y -o$Env:USERPROFILE\Documents\WindowsPowerShell\Modules"
  $zproc.WaitForExit()
  Touch-File "$PackerLogs\PSWindowsUpdate.installed"
}

# Need to guard against system going into standby for long updates
Write-Host "Disabling Sleep timers"
Disable-PC-Sleep

# Run the (Optional) Installation Package File.
$packageFile = Get-ChildItem -Path $PackageDir | ? { $_.Name -match '.package.ps1$'} | Select-Object -First 1
if ($packageFile -eq $null) {
  Write-Warning "No additional packages found in $PackageDir"
}
Else {
  & ($packageFile.Fullname)
}
# Run Windows Update - this will repeat as often as needed through the Invoke-Reboot cycle.
# When no more reboots are needed, the script falls through to the end.
Enable-UpdatesFromInternalWSUS

Write-Host "Searching for Windows Updates"
Get-WUInstall -AcceptAll -UpdateType Software -IgnoreReboot


if (Test-PendingReboot) { Invoke-Reboot }

# Disable UAC - this is boxstarter cmdlet that we need to replace.
#Write-Host "Disable UAC"
#Disable-UAC

# Enable Remote Desktop (with reduce authentication resetting here again)
#Write-Host "Enable Remote Desktop"
# TBD - Boxstarter Command
#Enable-RemoteDesktop -DoNotRequireUserLevelAuthentication
#netsh advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow

# Add WinRM Firewall Rule
Write-Host "Setting up winrm"
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

$enableArgs=@{Force=$true}
try {
 $command=Get-Command Enable-PSRemoting
  if($command.Parameters.Keys -contains "skipnetworkprofilecheck"){
      $enableArgs.skipnetworkprofilecheck=$true
  }
}
catch {
  $global:error.RemoveAt(0)
}
Enable-PSRemoting @enableArgs
Enable-WSManCredSSP -Force -Role Server
# NOTE - This is insecure but can be shored up in later customisation.  Required for Vagrant and other provisioning tools
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
Write-Host "WinRM setup complete"

Clear-RebootFiles
