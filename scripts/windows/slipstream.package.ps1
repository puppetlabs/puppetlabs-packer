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

if (-not (Test-Path "A:\NET462.installed"))
{
  # Install .Net Framework 4.5.2
  Write-BoxstarterMessage "Installing .Net 4.6.2"
  choco install dotnet-4.6.2 -y --install-arguments="/q /norestart"
  Touch-File "A:\NET462.installed"
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

# Setup Dism Directories
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
