#
# Install the various packages that we need to get this machine up on the air as a build/test box
#

$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

Write-Output "Installing Puppet Agent..."
if ("$ARCH" -eq "x86") {
  $PuppetMSIUrl = "https://downloads.puppetlabs.com/windows/puppet-agent-x86-latest.msi"
} else {
  $PuppetMSIUrl = "https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi"
}

# Install Puppet Agent
Download-File "$PuppetMSIUrl" $PackerDownloads\puppet-agent.msi
Start-Process -Wait "msiexec" @SprocParms -ArgumentList "/i $PackerDownloads\puppet-agent.msi /qn /norestart PUPPET_AGENT_STARTUP_MODE=manual"
Write-Output "Installed Puppet Agent..."

If ( $WindowsServerCore ) {
  Write-Output "Skipping Browser and Notepad++ installs for Windows Core"
}
else {

  Write-Output "Installing Google Chrome Browser"
  Download-File http://buildsources.delivery.puppetlabs.net/windows/googlechrome/ChromeSetup-$ARCH.exe $PackerDownloads\ChromeSetup-$ARCH.exe
  Start-Process -Wait "$PackerDownloads\ChromeSetup-$ARCH.exe" @SprocParms -ArgumentList "/silent /install"
  Write-Output "Google Chrome Browser Installed"

  Write-Output "Installing Notepad++"
  Download-File http://buildsources.delivery.puppetlabs.net/windows/notepadplusplus/npp.7.2.2.Installer-$ARCH.exe $PackerDownloads\npp.7.2.2.Installer-$ARCH.exe
  Start-Process -Wait "$PackerDownloads\npp.7.2.2.Installer-$ARCH.exe" @SprocParms -ArgumentList "/S"
  Write-Output "Notepad++ Installed"
}

Write-Output "Installing Git For Windows"
Download-File http://buildsources.delivery.puppetlabs.net/windows/gitforwin/Git-2.11.0-$ARCH.exe  $PackerDownloads\Git-2.11.0-$ARCH.exe
Start-Process -Wait "$PackerDownloads\Git-2.11.0-$ARCH.exe" @SprocParms -ArgumentList "/VERYSILENT /LOADINF=A:\gitforwin.inf"
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
  Download-File http://buildsources.delivery.puppetlabs.net/windows/sysinternals/$_.zip $PackerDownloads\$_.zip
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
