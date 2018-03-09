#
# Install the various packages that we need to get this machine up on the air as a build/test box
#

$ErrorActionPreference = 'Stop'

. C:\Packer\Scripts\windows-env.ps1

If ( $WindowsServerCore ) {
  Write-Output "Skipping Browser and Notepad++ installs for Windows Core"
}
else {

  Write-Output "Installing Google Chrome Browser"
  Download-File "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/googlechrome/ChromeSetup-$ARCH.exe" "$PackerDownloads\ChromeSetup-$ARCH.exe"
  Start-Process -Wait "$PackerDownloads\ChromeSetup-$ARCH.exe" @SprocParms -ArgumentList "/silent /install"
  Write-Output "Google Chrome Browser Installed"

  $NotePadInstaller = "npp.7.5.1.Installer-$ARCH.exe"
  Write-Output "Installing Notepad++ $NotePadInstaller"
  Download-File "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/notepadplusplus/$NotePadInstaller" "$PackerDownloads\$NotePadInstaller"
  Start-Process -Wait "$PackerDownloads\$NotePadInstaller" @SprocParms -ArgumentList "/S"
  Write-Output "Notepad++ Installed"
}

$GitForWinInstaller = "Git-2.15.0-$ARCH.exe"
Write-Output "Installing Git For Windows $GitForWinInstaller"
Download-File "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/gitforwin/$GitForWinInstaller"  "$PackerDownloads\$GitForWinInstaller"
Start-Process -Wait "$PackerDownloads\$GitForWinInstaller" @SprocParms -ArgumentList "/VERYSILENT /LOADINF=$PackerConfig\gitforwin.inf"
Write-Output "Git For Windows Installed"

# Install Sysinternals - to special tools directory as we may want to remove chocolatey
Write-Output "Installing Sysinternal Tools"
$SysInternalsTools = @(
  'procexp',
  'procmon',
  'pstools',
  'bginfo',
  'autologon'
)
$SysInternalsTools | ForEach-Object {
  Download-File https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/sysinternals/$_.zip $PackerDownloads\$_.zip
  # PS2 has a bug with "Start-Process -Wait" which can cause it to fail if the command finishes "too quickly", so using this
  # workaround to address random failures (especially with Win-2012)
  $zproc = Start-Process "$7zip" @SprocParms -ArgumentList "x $PackerDownloads\$_.zip -y -o$SysInternals"
  $zproc.WaitForExit()
}

Write-Output "Updating path with $SysInternals"
$RegPath = 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
$OldPath = (Get-ItemProperty -Path $RegPath -Name PATH).Path
$NewPath = $OldPath + ';' + $SysInternals
Set-ItemProperty -Path $RegPath -Name PATH -Value $NewPath

Write-Output "Sysinternal Tools Installed"

# Sleep to let console log catch up (and get captured by packer)
Start-Sleep -Seconds 20
