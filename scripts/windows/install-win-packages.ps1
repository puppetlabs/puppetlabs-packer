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
Download-File "$PuppetMSIUrl" $PackerDownloads\puppet-agent.msi
Start-Process -Wait "msiexec" -ArgumentList "/i $PackerDownloads\puppet-agent.msi /qn /norestart PUPPET_AGENT_STARTUP_MODE=manual"
Write-Host "Installed Puppet Agent..."

Write-Host "Installing Google Chrome Browser"
Download-File http://buildsources.delivery.puppetlabs.net/windows/googlechrome/ChromeSetup-$ARCH.exe $PackerDownloads\ChromeSetup-$ARCH.exe
Start-Process -Wait "$PackerDownloads\ChromeSetup-$ARCH.exe" -ArgumentList "/silent /install"
Write-Host "Google Chrome Browser Installed"

# Install Notepad++
Write-Host "Installing Notepad++"
Download-File http://buildsources.delivery.puppetlabs.net/windows/notepadplusplus/npp.7.2.2.Installer-$ARCH.exe $PackerDownloads\npp.7.2.2.Installer-$ARCH.exe
Start-Process -Wait "$PackerDownloads\npp.7.2.2.Installer-$ARCH.exe" -ArgumentList "/S"
Write-Host "Notepad++ Installed"

Write-Host "7zip"
Download-File http://buildsources.delivery.puppetlabs.net/windows/7zip/7z1602-$ARCH.exe  $PackerDownloads\7z1602-$ARCH.exe
Start-Process -Wait "$PackerDownloads\7z1602-$ARCH.exe" -ArgumentList "/S"
Write-Host "7zip Installed"

# Install Sysinternals - to special tools directory as we may want to remove chocolatey
Write-Host "Installing Sysinternal Tools"
$ostring = "-o" + $SysInternals

Download-File http://buildsources.delivery.puppetlabs.net/windows/sysinternals/procexp.zip $PackerDownloads\procexp.zip
& $7zip x C:\Packer\Downloads\procexp.zip -y $ostring

Download-File http://buildsources.delivery.puppetlabs.net/windows/sysinternals/procmon.zip $PackerDownloads\procmon.zip
& $7zip x C:\Packer\Downloads\procmon.zip -y $ostring

Download-File http://buildsources.delivery.puppetlabs.net/windows/sysinternals/pstools.zip $PackerDownloads\pstools.zip
& $7zip x C:\Packer\Downloads\pstools.zip -y $ostring

Download-File http://buildsources.delivery.puppetlabs.net/windows/sysinternals/sdelete.zip $PackerDownloads\sdelete.zip
& $7zip x C:\Packer\Downloads\sdelete.zip -y $ostring

Download-File http://buildsources.delivery.puppetlabs.net/windows/sysinternals/bginfo.zip $PackerDownloads\bginfo.zip
& $7zip x C:\Packer\Downloads\bginfo.zip -y $ostring

Download-File http://buildsources.delivery.puppetlabs.net/windows/sysinternals/autologon.zip $PackerDownloads\autologon.zip
& $7zip x C:\Packer\Downloads\autologon.zip -y $ostring

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
