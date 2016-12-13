$ErrorActionPreference = "Stop"

. A:\windows-env.ps1

# Boxstarter options
$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

if (Test-PendingReboot){ Invoke-Reboot }

Write-BoxstarterMessage "Disabling Hiberation..."
Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateFileSizePercent' -Value 0
Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateEnabled' -Value 0

# Set all network adapters Private
Write-BoxstarterMessage "Set all network adapters private"
$net = get-netconnectionprofile;Set-NetConnectionProfile -Name $net.Name -NetworkCategory Private

if (-not (Test-Path "A:\NET45.installed"))
{
  # Install .Net Framework 4.5.2
  Write-BoxstarterMessage "Installing .Net 4.5"
  choco install dotnet4.5 -y
  Touch-File "A:\NET45.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

# Create Dism directories and copy files over.
# This allows errors to be handled manually in event of dism failures

New-Item -ItemType directory -Force -Path C:\Packer
New-Item -ItemType directory -Force -Path C:\Packer\Dism
New-Item -ItemType directory -Force -Path C:\Packer\Downloads
New-Item -ItemType directory -Force -Path C:\Packer\Dism\Mount
New-Item -ItemType directory -Force -Path C:\Packer\Dism\Logs

$MSUPackageDir = "$ENV:WINDIR\SoftwareDistribution\Download\SlipMSUPackages"
New-Item -ItemType directory -Force -Path $MSUPackageDir

# Forget downloading any windows update pass - download the updates we need directly.
# (KB3199986) - http://download.windowsupdate.com/c/msdownload/update/software/crup/2016/10/windows10.0-kb3199986-x64_5d4678c30de2de2bd7475073b061d0b3b2e5c3be.msu
# (KB3200970) - Cumulative Update - http://download.windowsupdate.com/d/msdownload/update/software/secu/2016/11/windows10.0-kb3200970-x64_3fa1daafc46a83ed5d0ecbd0a811e1421b7fad5a.msu

if (-not (Test-Path "A:\Win10.Downloads"))
{
  # Install Windows Rollup Update first.
  Write-Host "Download KB KB3199986"
  Download-File "http://download.windowsupdate.com/c/msdownload/update/software/crup/2016/10/windows10.0-kb3199986-x86_bf0ba5d3aba65e64d16c3bbe309e2ef67831c26f.msu"  "$MSUPackageDir\windows10.0-kb3199986-x86_bf0ba5d3aba65e64d16c3bbe309e2ef67831c26f.msu"
  Write-Host "Download Main CU - KB3200970"
  Download-File "http://download.windowsupdate.com/c/msdownload/update/software/crup/2016/11/windows10.0-kb3201845-x86_5561f8fa58a6c59c86be7941aa600b1cffe33a2e.msu"  "$MSUPackageDir\windows10.0-kb3201845-x86_5561f8fa58a6c59c86be7941aa600b1cffe33a2e.msu"
  Write-Host "Downloads complete"
  Touch-File "A:\Win10.Downloads"
  if (Test-PendingReboot) { Invoke-Reboot }
}


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
