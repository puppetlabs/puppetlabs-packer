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
  Add-WindowsFeature Desktop-Experience -ErrorAction SilentlyContinue
  Touch-File "A:\DesktopExperience.installed"
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
