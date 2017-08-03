#
# Install the various packages that we need to get this machine up on the air as a build/test box
#

$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

Write-Host "Installing Puppet Agent..."
if ("$ARCH" -eq "x86") {
  $PuppetMSIUrl = "https://downloads.puppetlabs.com/windows/puppet-agent-x86-latest.msi"
} else {
  $PuppetMSIUrl = "https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi"
}

# Define common Start-Process params appropriate for running the install setups.
# Main one is -Wait (until setup is complete).
# PassThru and NoNewWindow also relevant to ensure any installer console output is properly captured
$SprocParms = @{'PassThru'=$true;
                'NoNewWindow'=$true
}

Download-File "$PuppetMSIUrl" $PackerDownloads\puppet-agent.msi
Start-Process -Wait "msiexec" @SprocParms -ArgumentList "/i $PackerDownloads\puppet-agent.msi /qn /norestart PUPPET_AGENT_STARTUP_MODE=manual"
Write-Host "Installed Puppet Agent..."

If ( $WindowsServerCore ) {
  Write-Host "Skipping Browser and Notepad++ installs for Windows Core"
}
else {

  Write-Host "Installing Google Chrome Browser"
  Download-File http://buildsources.delivery.puppetlabs.net/windows/googlechrome/ChromeSetup-$ARCH.exe $PackerDownloads\ChromeSetup-$ARCH.exe
  Start-Process -Wait "$PackerDownloads\ChromeSetup-$ARCH.exe" @SprocParms -ArgumentList "/silent /install"
  Write-Host "Google Chrome Browser Installed"

  Write-Host "Installing Notepad++"
  Download-File http://buildsources.delivery.puppetlabs.net/windows/notepadplusplus/npp.7.2.2.Installer-$ARCH.exe $PackerDownloads\npp.7.2.2.Installer-$ARCH.exe
  Start-Process -Wait "$PackerDownloads\npp.7.2.2.Installer-$ARCH.exe" @SprocParms -ArgumentList "/S"
  Write-Host "Notepad++ Installed"
}

Write-Host "Installing 7zip"
Download-File http://buildsources.delivery.puppetlabs.net/windows/7zip/7z1602-$ARCH.exe  $PackerDownloads\7z1602-$ARCH.exe
Start-Process -Wait "$PackerDownloads\7z1602-$ARCH.exe" @SprocParms -ArgumentList "/S"
Write-Host "7zip Installed"

Write-Host "Installing Git For Windows"
Download-File http://buildsources.delivery.puppetlabs.net/windows/gitforwin/Git-2.11.0-$ARCH.exe  $PackerDownloads\Git-2.11.0-$ARCH.exe
Start-Process -Wait "$PackerDownloads\Git-2.11.0-$ARCH.exe" @SprocParms -ArgumentList "/VERYSILENT /LOADINF=A:\gitforwin.inf"
Write-Host "Git For Windows Installed"

# Install Sysinternals - to special tools directory as we may want to remove chocolatey
Write-Host "Installing Sysinternal Tools"
$SysInternalsTools = @(
  'procexp',
  'procmon',
  'pstools',
  'bginfo',
  'autologon'
)
$SysInternalsTools | % {
  Download-File http://buildsources.delivery.puppetlabs.net/windows/sysinternals/$_.zip $PackerDownloads\$_.zip
  # PS2 has a bug with "Start-Process -Wait" which can cause it to fail if the command finishes "too quickly", so using this
  # workaround to address random failures (especially with Win-2012)
  $zproc = Start-Process "$7zip" @SprocParms -ArgumentList "x $PackerDownloads\$_.zip -y -o$SysInternals"
  $zproc.WaitForExit()
}

Write-Host "Updating path with $SysInternals"
$RegPath = 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
$OldPath = (Get-ItemProperty -Path $RegPath -Name PATH).Path
$NewPath = $OldPath + ';' + $SysInternals
Set-ItemProperty -Path $RegPath -Name PATH -Value $NewPath

# Update PATH to include sysinternals

Write-Host "Sysinternal Tools Installed"

# Put in registry keys to suppress the EULA popup on first use.
# (since puppet modules don't support HKCU)

reg.exe load HKLM\DEFUSER c:\users\default\ntuser.dat

Set-UserKey 'Software\Sysinternals\Process Explorer' 'EulaAccepted'       'REG_DWORD' 1
Set-UserKey 'Software\Sysinternals\Process Monitor'  'EulaAccepted'       'REG_DWORD' 1
Set-UserKey 'Software\Sysinternals\PsExec'           'EulaAccepted'       'REG_DWORD' 1
Set-UserKey 'Software\Sysinternals\PsFile'           'EulaAccepted'       'REG_DWORD' 1
Set-UserKey 'Software\Sysinternals\PsGetSid'         'EulaAccepted'       'REG_DWORD' 1
Set-UserKey 'Software\Sysinternals\PsInfo'           'EulaAccepted'       'REG_DWORD' 1
Set-UserKey 'Software\Sysinternals\PsKill'           'EulaAccepted'       'REG_DWORD' 1
Set-UserKey 'Software\Sysinternals\PsList'           'EulaAccepted'       'REG_DWORD' 1
Set-UserKey 'Software\Sysinternals\PsLoggedOn'       'EulaAccepted'       'REG_DWORD' 1
Set-UserKey 'Software\Sysinternals\PsLogList'        'EulaAccepted'       'REG_DWORD' 1
Set-UserKey 'Software\Sysinternals\PsPasswd'         'EulaAccepted'       'REG_DWORD' 1
Set-UserKey 'Software\Sysinternals\PsService'        'EulaAccepted'       'REG_DWORD' 1
Set-UserKey 'Software\Sysinternals\PsShutdown'       'EulaAccepted'       'REG_DWORD' 1
Set-UserKey 'Software\Sysinternals\PsSuspend'        'EulaAccepted'       'REG_DWORD' 1
Set-UserKey 'Software\Sysinternals\PsTools'          'EulaAccepted'       'REG_DWORD' 1

reg.exe unload HKLM\DEFUSER

# Sleep to let console log catch up (and get captured by packer)
Start-Sleep -Seconds 20
