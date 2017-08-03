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

# Make sure network connection is private
Write-BoxstarterMessage "Setting network adapters to private"
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$connections = $networkListManager.GetNetworkConnections()

if (-not (Test-Path "A:\NET35.Installed"))
{
  # Install .Net 3.5.1
  Write-Host ".Net 3.5.1"
  Download-File "http://buildsources.delivery.puppetlabs.net/windows/win-2008-ps2/dotnetfx35setup.exe"  "$ENV:TEMP\dotnetfx35setup.exe"
  Start-Process -Wait "$ENV:TEMP\dotnetfx35setup.exe" -ArgumentList "/q"
  Write-Host ".Net 3.5.1 Installed"
  Touch-File "A:\NET35.Installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

if (-not (Test-Path "A:\WinUpdate.Installed"))
{
  # Install .Net 3.5.1
  Write-Host "Updating Windows Update agent"
  Download-File "http://buildsources.delivery.puppetlabs.net/windows/win-2008-ps2/windowsupdateagent30-x64.exe"  "$ENV:TEMP\windowsupdateagent30-x64.exe"
  Start-Process -Wait "$ENV:TEMP\windowsupdateagent30-x64.exe" -ArgumentList "/q"
  Write-Host "Updating Windows Update agent"
  Touch-File "A:\WinUpdate.Installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

if (-not (Test-Path "A:\Win2008.Patches"))
{
  $patches = @(
    'http://download.windowsupdate.com/d/msdownload/update/software/secu/2016/04/windows6.0-kb3153199-x64_ff7991c9c3465327640c5fdf296934ac12467fd0.msu',
    "http://download.windowsupdate.com/d/msdownload/update/software/secu/2016/04/windows6.0-kb3145739-x64_918212eb27224cf312f865e159f172a4b8a75b76.msu"
  )
  $patches | % { Install_Win_Patch -PatchUrl $_ }

  Touch-File "A:\Win2008.Patches"
  if (Test-PendingReboot) { Invoke-Reboot }
}

# Run the Packer Update Sequence
Install-PackerWindowsUpdates -DisableWUSA

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
# Set service to start automatically (not delayed)
Set-Service "WinRM" -StartupType Automatic

Write-BoxstarterMessage "WinRM setup complete"

# End
