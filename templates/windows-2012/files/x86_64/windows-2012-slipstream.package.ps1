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

if (-not (Test-Path "A:\NET45.installed"))
{
  # Install .Net Framework 4.5.2
  Write-BoxstarterMessage "Installing .Net 4.5"
  choco install dotnet4.5.2 -y
  Touch-File "A:\NET45.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

# Install all patches related to Windows Update and Servicing Stack - These were gleaned from Google searches and
# The following lists:
#        https://blogs.technet.microsoft.com/chad/2015/01/21/current-windows-server-2012-r2-windows-8-8-1-update-rollups/
#        https://social.technet.microsoft.com/wiki/contents/articles/23820.windows-8-and-windows-server-2012-list-of-rollup-updates.aspx#General_availability
if (-not (Test-Path "A:\Win2012.Patches"))
{
  $patches = @(
    'http://download.windowsupdate.com/msdownload/update/software/crup/2012/10/windows8-rt-kb2761094-x64_7f31aa2f3ba35dae806363e88c3757776b4a7266.msu',
    'http://download.windowsupdate.com/msdownload/update/software/crup/2012/10/windows8-rt-kb2764870-x64_196e3394e91fb46f536181406fe4e533d3c64b07.msu',
    'http://download.windowsupdate.com/msdownload/update/software/crup/2012/09/windows8-rt-kb2756872-x64_99dcb07efbf01d02bc5e8a2d49ec1dddfd786dfb.msu',
    'http://download.windowsupdate.com/c/msdownload/update/software/crup/2014/07/windows8-rt-kb2937636-x64_29e0b587c8f09bcf635c1b79d09c00eef33113ec.msu',
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
