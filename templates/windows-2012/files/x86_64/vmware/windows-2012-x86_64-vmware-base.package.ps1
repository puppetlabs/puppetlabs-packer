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

if (-not (Test-Path "A:\DesktopExperience.installed"))
{
  # Enable Desktop experience to get cleanmgr
  Write-BoxstarterMessage "Enable Desktop-Experience"
  Add-WindowsFeature Desktop-Experience
  Touch-File "A:\DesktopExperience.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

# Servicing Stack Patches that don't get slipstreamed properly to be installed.
if (-not (Test-Path "A:\Win2012.Patches"))
{
  $patches = @(
    'http://download.windowsupdate.com/c/msdownload/update/software/updt/2015/04/windows8-rt-kb3003729-x64_e95e2c0534a7f3e8f51dd9bdb7d59e32f6d65612.msu',
    'http://download.windowsupdate.com/d/msdownload/update/software/updt/2015/09/windows8-rt-kb3096053-x64_930f557083e97c7e22e7da133e802afca4963d4f.msu',
    'http://download.windowsupdate.com/d/msdownload/update/software/crup/2016/06/windows8-rt-kb3173426-x64_ecf1b38d9e3cdf1eace07b9ddbf6f57c1c9d9309.msu'
  )
  $patches | % { Install_Win_Patch -PatchUrl $_ }

  Touch-File "A:\Win2012.Patches"
  if (Test-PendingReboot) { Invoke-Reboot }
}

# Run the Packer Update Sequence
Install-PackerWindowsUpdates

# Disable UAC
Write-BoxstarterMessage "Disable UAC"
Disable-UAC

# Enable Remote Desktop (with reduce authentication resetting here again)
Write-BoxstarterMessage "Enable Remote Desktop"
Enable-RemoteDesktop -DoNotRequireUserLevelAuthentication
netsh advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow

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
Write-BoxstarterMessage "WinRM setup complete"

# End
