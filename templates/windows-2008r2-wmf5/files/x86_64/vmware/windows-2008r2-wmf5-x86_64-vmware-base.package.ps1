$ErrorActionPreference = "Stop"

. A:\windows-env.ps1

# Boxstarter options
$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

if (Test-PendingReboot){ Invoke-Reboot }

# Need to guard against system going into standby for long updates
Write-BoxstarterMessage "Disabling Sleep timers"
Disable-PC-Sleep

if (-not (Test-Path "A:\NET35.installed"))
{
  # Enable .Net 3.5 (needed for Puppet csc compiles)
  Write-BoxstarterMessage "Enable .Net 3.5"
  DISM /Online /Enable-Feature /FeatureName:NetFx3
  # And add desktop experience for cleanmgr
  Write-BoxstarterMessage "Enable Desktop-Experience"
  dism /online /enable-feature /FeatureName:DesktopExperience /featurename:InkSupport /norestart
  Touch-File "A:\NET35.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

if (-not (Test-Path "A:\KB2852386.installed"))
{
  # Install the WinSxS cleanup patch
  Write-BoxstarterMessage "Installing Windows Update Cleanup Hotfix KB2852386"
  Install_Win_Patch "http://osmirror.delivery.puppetlabs.net/iso/windows/win-2008r2-msu/Windows6.1-KB2852386-v2-x64.msu"
  Touch-File "A:\KB2852386.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

if (-not (Test-Path "A:\NET45.installed"))
{
  # Install .Net Framework 4.5.2
  Write-BoxstarterMessage "Installing .Net 4.5"
  choco install dotnet4.5 -y
  Touch-File "A:\NET45.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

if (-not (Test-Path "A:\WMF4.installed"))
{
  # Install WMF 4 (Powershell)
  Write-BoxstarterMessage "Installing WFM 4"
  Install_Win_Patch -PatchUrl "http://buildsources.delivery.puppetlabs.net/windows/wmf5/Windows6.1-KB2819745-x64-MultiPkg.msu"
  Touch-File "A:\WMF4.installed"
  Invoke-Reboot
}

if (-not (Test-Path "A:\WMF5.installed"))
{
  # Install WMF 5 (Powershell)
  Write-BoxstarterMessage "Installing WFM 5"
  Install_Win_Patch -PatchUrl "http://buildsources.delivery.puppetlabs.net/windows/wmf5/Win7AndW2K8R2-KB3134760-x64.msu"
  Touch-File "A:\WMF5.installed"
  Invoke-Reboot
}

# Run the Packer Update Sequence
Install-PackerWindowsUpdates

# Enable RDP
Write-BoxstarterMessage "Enable Remote Desktop"
Enable-RemoteDesktop
netsh advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow

# Add WinRM Firewall Rule
Write-BoxstarterMessage "Adding Firewall rules for win-rm"
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

Write-BoxstarterMessage "Setup PSRemoting"
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
Write-BoxstarterMessage "Enable PS-Remoting -Force"
try {
  Enable-PSRemoting @enableArgs
}
catch {
  Write-BoxstarterMessage "Ignoring PSRemoting Error"
}

Write-BoxstarterMessage "Enable WSMandCredSSP"
Enable-WSManCredSSP -Force -Role Server


# NOTE - This is insecure but can be shored up in later customisation.  Required for Vagrant and other provisioning tools
Write-BoxstarterMessage "WinRM Settings"
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'
Write-BoxstarterMessage "WinRM setup complete"

# End
