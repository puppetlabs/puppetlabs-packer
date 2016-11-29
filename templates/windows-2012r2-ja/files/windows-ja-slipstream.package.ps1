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

Write-BoxstarterMessage "Disabling Hiberation..."
Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateFileSizePercent' -Value 0
Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateEnabled' -Value 0


reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"    /v "WUServer"       /t REG_SZ /d "http://10.32.163.228:8530" /f
reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"    /v "WUStatusServer" /t REG_SZ /d "http://10.32.163.228:8530" /f

reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 0 /f
reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 2 /f
reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "ScheduledInstallDay" /t REG_DWORD /d 0 /f
reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "ScheduledInstallTime" /t REG_DWORD /d 3 /f
reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "UseWUServer" /t REG_DWORD /d 1 /f

if (-not (Test-Path "A:\NET45.installed"))
{
  # Install .Net Framework 4.5.2
  Write-BoxstarterMessage "Installing .Net 4.5"
  choco install dotnet4.5 -y
  Touch-File "A:\NET45.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

$Win2012r2FixMsu = "Windows8.1-KB3021910-x64_ja.msu"
if (-not (Test-Path "A:\Win2012r2MSU.installed"))
{
  # Install Windows Rollup Update first.
  Write-Host "Install Windows 7 Rollup update"
  Download-File "http://osmirror.delivery.puppetlabs.net/iso/windows/win-2012r2-msu/$Win2012r2FixMsu"  "$ENV:TEMP\$Win2012r2FixMsu"
  Write-Host "Applying $Win2012r2FixMsu Patch"
  Start-Process -Wait "wusa.exe" -ArgumentList "$ENV:TEMP\$Win2012r2FixMsu /quiet /norestart"
  Touch-File "A:\Win2012r2MSU.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

# Install Updates and reboot until this is completed.
Install-WindowsUpdate -AcceptEula
if (Test-PendingReboot) { Invoke-Reboot }

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
