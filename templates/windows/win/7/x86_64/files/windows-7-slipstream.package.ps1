$ErrorActionPreference = "Stop"

# Customised Slipstream script for Windows-7 - this proves a bit more difficult than the "usual"
# Slipstream update process.
# Use a rollup update.

. A:\windows-env.ps1

# Boxstarter options
$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

if (Test-PendingReboot){ Invoke-Reboot }

# Need to guard against system going into standby for long updates
Write-BoxstarterMessage "Disabling Sleep timers"
Disable-PC-Sleep

# KB3020369 Windows6.1-KB3020369-x64
# KB3177467  Windows6.1-KB3177467-x64
if (-not (Test-Path "A:\KB2852386.installed"))
{
  # Install the WinSxS cleanup patch
  Write-BoxstarterMessage "Installing Windows Update Cleanup Hotfix KB2852386"
  Install_Win_Patch -PatchUrl "http://osmirror.delivery.puppetlabs.net/iso/windows/win-2008r2-msu/Windows6.1-KB2852386-v2-x64.msu"
  Touch-File "A:\KB2852386.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}
if (-not (Test-Path "A:\KB3020369.installed"))
{
  # Install the WinSxS cleanup patch
  Write-BoxstarterMessage "Installing Windows Update Cleanup Hotfix KB3020369"
  Install_Win_Patch -PatchUrl "http://osmirror.delivery.puppetlabs.net/iso/windows/win-2008r2-msu/Windows6.1-KB3020369-x64.msu"
  Touch-File "A:\KB3020369.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}
if (-not (Test-Path "A:\KB3177467.installed"))
{
  # Install the WinSxS cleanup patch
  Write-BoxstarterMessage "Installing Windows Update Cleanup Hotfix KB3177467"
  Install_Win_Patch -PatchUrl "http://osmirror.delivery.puppetlabs.net/iso/windows/win-2008r2-msu/Windows6.1-KB3177467-x64.msu"
  Touch-File "A:\KB3177467.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}



$Win7RollupMsu = "windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"
if (-not (Test-Path "A:\Win7MSU.installed"))
{
  # Install Windows Rollup Update first.
  Write-Output "Install Windows 7 Rollup update"
  Download-File "http://osmirror.delivery.puppetlabs.net/iso/windows/win-7-msu/$Win7RollupMsu"  "$ENV:TEMP\$Win7RollupMsu"
  Write-Output "Applying $Win7RollupMsu Patch"
  Start-Process -Wait "wusa.exe" -ArgumentList "$ENV:TEMP\$Win7RollupMsu /quiet /norestart"
  Touch-File "A:\Win7MSU.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

# Run the Packer Update Sequence
Install-PackerWindowsUpdates


# Create Dism directories and copy files over.
# This allows errors to be handled manually in event of dism failures

New-Item -ItemType directory -Force -Path C:\Packer
New-Item -ItemType directory -Force -Path C:\Packer\Dism
New-Item -ItemType directory -Force -Path C:\Packer\Downloads
New-Item -ItemType directory -Force -Path C:\Packer\Dism\Mount
New-Item -ItemType directory -Force -Path C:\Packer\Dism\Logs

Copy-Item A:\windows-env.ps1 C:\Packer\Dism
Copy-Item A:\generate-slipstream.ps1 C:\Packer\Dism
Copy-Item A:\slipstream-filter C:\Packer\Dism

# Add WinRM Firewall Rule
Write-BoxstarterMessage "Setting up winrm"
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
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'
Write-BoxstarterMessage "WinRM setup complete"

# End
