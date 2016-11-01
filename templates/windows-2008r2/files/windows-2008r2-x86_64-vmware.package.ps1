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

# Enable RDP
Write-BoxstarterMessage "Enable Remote-Desktop"
Enable-RemoteDesktop
netsh advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow


if (-not (Test-Path "A:\NET35.installed"))
{
  # Enable .Net 3.5 (needed for Puppet csc compiles) and other features
  Write-BoxstarterMessage "Enable .Net 3.5"
  DISM /Online /Enable-Feature /FeatureName:NetFx3
  Write-BoxstarterMessage "Enable Desktop-Experience"
  dism /online /enable-feature /FeatureName:DesktopExperience /featurename:InkSupport /norestart
  Touch-File "A:\NET35.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

if (-not (Test-Path "A:\KB2852386.installed"))
{
  # Install the WinSxS cleanup patch
  Write-BoxstarterMessage "Installing Windows Update Cleanup Hotfix KB2852386"
  Download-File http://osmirror.delivery.puppetlabs.net/iso/windows/win-2008r2-msu/Windows6.1-KB2852386-v2-x64.msu  $ENV:TEMP\Windows6.1-KB2852386-v2-x64.msu
  Start-Process -Wait "wusa.exe" -ArgumentList "$ENV:TEMP\Windows6.1-KB2852386-v2-x64.msu /quiet /norestart"
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

# Install Updates and reboot until this is completed.
Install-WindowsUpdate -AcceptEula
if (Test-PendingReboot) { Invoke-Reboot }

# Remove the pagefile
Write-BoxstarterMessage "Removing page file.  Recreates on next boot"
$pageFileMemoryKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $pageFileMemoryKey -Name PagingFiles -Value ""

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

# Re-Enable AutoAdminLogon
$WinlogonPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $WinlogonPath -Name AutoAdminLogon -Value "1" -ErrorAction SilentlyContinue
Set-ItemProperty -Path $WinlogonPath -Name DefaultUserName -Value "Administrator" -ErrorAction SilentlyContinue
Set-ItemProperty -Path $WinlogonPath -Name DefaultPassword -Value "PackerAdmin" -ErrorAction SilentlyContinue

# End
