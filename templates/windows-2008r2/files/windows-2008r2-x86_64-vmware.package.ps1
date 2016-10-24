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

# Install .Net Framework 4.5.2
Write-BoxstarterMessage "Installing .Net 4.5"
choco install dotnet4.5 -y
if (Test-PendingReboot) { Invoke-Reboot }

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
Write-BoxstarterMessage "WinRM setup complete"

# Re-Enable AutoAdminLogon
$WinlogonPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $WinlogonPath -Name AutoAdminLogon -Value "1" -ErrorAction SilentlyContinue
Set-ItemProperty -Path $WinlogonPath -Name DefaultUserName -Value "Administrator" -ErrorAction SilentlyContinue
Set-ItemProperty -Path $WinlogonPath -Name DefaultPassword -Value "PackerAdmin" -ErrorAction SilentlyContinue

# End
