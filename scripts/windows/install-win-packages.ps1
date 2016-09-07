#
# Install the various packages that we need to get this machine up on the air as a build/test box
#

$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

Write-Host "Installing Puppet Agent..."
Download-File https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi $PackerDownloads\puppet-agent.msi
Start-Process -Wait "msiexec" -ArgumentList "/i $PackerDownloads\puppet-agent.msi /qn /norestart PUPPET_AGENT_STARTUP_MODE=manual"
Write-Host "Installed Puppet Agent..."

Write-Host "Installing Google Chrome Browser"
Download-File http://buildsources.delivery.puppetlabs.net/windows/googlechrome/ChromeSetup_x86_64.exe $PackerDownloads\ChromeSetup_x86_64.exe
Start-Process -Wait "$PackerDownloads\ChromeSetup_x86_64.exe" -ArgumentList "/silent /install"
Write-Host "Google Chrome Browser Installed"

# Install Notepad++
Write-Host "Installing Notepad++"
Download-File http://buildsources.delivery.puppetlabs.net/windows/notepadplusplus/npp.6.9.2.Installer.exe $PackerDownloads\npp.6.9.2.Installer.exe
Start-Process -Wait "$PackerDownloads\npp.6.9.2.Installer.exe" -ArgumentList "/S"
Write-Host "Notepad++ Installed"

Write-Host "7zip"
Download-File http://buildsources.delivery.puppetlabs.net/windows/7zip/7z1602-x64.exe  $PackerDownloads\7z1602-x64.exe
Start-Process -Wait "$PackerDownloads\7z1602-x64.exe" -ArgumentList "/S"
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

# First a helper function
function AcceptSysInternalsEULA {
param (
  [string]$regkeyroot
 )
   Write-Host "Setting Sysinternals Registry Keys for $regkeyroot"

   reg.exe ADD "$regkeyroot\Software\Sysinternals\Process Explorer" /v EulaAccepted /t REG_DWORD /d 1 /f
   reg.exe ADD "$regkeyroot\Software\Sysinternals\Process Monitor"  /v EulaAccepted /t REG_DWORD /d 1 /f
   reg.exe ADD "$regkeyroot\Software\Sysinternals\PsExec"           /v EulaAccepted /t REG_DWORD /d 1 /f
   reg.exe ADD "$regkeyroot\Software\Sysinternals\PsFile"           /v EulaAccepted /t REG_DWORD /d 1 /f
   reg.exe ADD "$regkeyroot\Software\Sysinternals\PsGetSid"         /v EulaAccepted /t REG_DWORD /d 1 /f
   reg.exe ADD "$regkeyroot\Software\Sysinternals\PsInfo"           /v EulaAccepted /t REG_DWORD /d 1 /f
   reg.exe ADD "$regkeyroot\Software\Sysinternals\PsKill"           /v EulaAccepted /t REG_DWORD /d 1 /f
   reg.exe ADD "$regkeyroot\Software\Sysinternals\PsList"           /v EulaAccepted /t REG_DWORD /d 1 /f
   reg.exe ADD "$regkeyroot\Software\Sysinternals\PsLoggedOn"       /v EulaAccepted /t REG_DWORD /d 1 /f
   reg.exe ADD "$regkeyroot\Software\Sysinternals\PsLogList"        /v EulaAccepted /t REG_DWORD /d 1 /f
   reg.exe ADD "$regkeyroot\Software\Sysinternals\PsPasswd"         /v EulaAccepted /t REG_DWORD /d 1 /f
   reg.exe ADD "$regkeyroot\Software\Sysinternals\PsService"        /v EulaAccepted /t REG_DWORD /d 1 /f
   reg.exe ADD "$regkeyroot\Software\Sysinternals\PsShutdown"       /v EulaAccepted /t REG_DWORD /d 1 /f
   reg.exe ADD "$regkeyroot\Software\Sysinternals\PsSuspend"        /v EulaAccepted /t REG_DWORD /d 1 /f
   reg.exe ADD "$regkeyroot\Software\Sysinternals\PsTools"          /v EulaAccepted /t REG_DWORD /d 1 /f
}

# Accept for current user.
AcceptSysInternalsEULA HKCU

# Same for the Default User
reg.exe load HKLM\DEFUSER c:\users\default\ntuser.dat
AcceptSysInternalsEULA HKLM\DEFUSER
reg.exe unload HKLM\DEFUSER
