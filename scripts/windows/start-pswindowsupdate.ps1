param (
  [string]$LoginUser = "Administrator",
  [string]$LoginPassword = "PackerAdmin",
  [switch] $UseStartupWorkaround = $false
)
$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1
$PackageDir = 'A:\'

function Install-StartupWorkaround {
     Set-ItemProperty `
             -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" `
             -Name Shell -Value "PowerShell.exe -NoExit"

     $profileDir = (Split-Path -Parent $PROFILE)
     if (!(Test-Path $profileDir)) {
         New-Item -Type Directory $profileDir
     }

     Copy-Item -Force A:\startup-profile.ps1 $PROFILE
 }

 if ($UseStartupWorkaround) {
     Write-Warning "Using PowerShell profile workaround for startup items"
     Install-StartupWorkaround
 }

 # Install latest .Net package prior to any windows updates.
Install-DotNetLatest

# Download and install 7za now as its needed here and is useful going forward.
Write-Host "Installing 7zip"
Download-File http://buildsources.delivery.puppetlabs.net/windows/7zip/7z1602-$ARCH.exe  $Env:TEMP\7z1602-$ARCH.exe
Start-Process -Wait "$Env:TEMP\7z1602-$ARCH.exe" @SprocParms -ArgumentList "/S"
Write-Host "7zip Installed"

# Download and install PSWindows Update Modules.
Download-File "http://buildsources.delivery.puppetlabs.net/windows/pswindowsupdate/PSWindowsUpdate.zip" "$Env:TEMP/pswindowsupdate.zip"
$zproc = Start-Process "$7zip" @SprocParms -ArgumentList "x $Env:TEMP/pswindowsupdate.zip -y -o$Env:USERPROFILE\Documents\WindowsPowerShell\Modules"
$zproc.WaitForExit()
$zproc = Start-Process "$7zip" @SprocParms -ArgumentList "x $Env:TEMP/pswindowsupdate.zip -y -o$Env:WINDIR\System32\WindowsPowerShell\v1.0\Modules"
$zproc.WaitForExit()

# Need to guard against system going into standby for long updates
Write-Host "Disabling Sleep timers"
Disable-PC-Sleep

# Run the Installation Package File.
$packageFile = Get-ChildItem -Path $PackageDir | ? { $_.Name -match '.package.ps1$'} | Select-Object -First 1
if ($packageFile -eq $null) {
  Write-Warning "No boxstarter packages found in $PackageDir"
  return
}
($packageFile.Fullname)

# Run Windows Update until its complete.
# Will recursively arrive back in here until all updates have been applied.

# Disable UAC - this is boxstarter cmdlet that we need to replace.
#Write-Host "Disable UAC"
#Disable-UAC

# Enable Remote Desktop (with reduce authentication resetting here again)
Write-Host "Enable Remote Desktop"
Enable-RemoteDesktop -DoNotRequireUserLevelAuthentication
netsh advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow

# Add WinRM Firewall Rule
Write-Host "Setting up winrm"
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
Write-Host "WinRM setup complete"
