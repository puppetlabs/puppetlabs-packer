#
# Install the various packages that we need to get this machine up on the air as a build/test box
#

$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

Write-Host "Installing Puppet Agent..."
chocolatey install puppet-agent --yes --force
Write-Host "Installed Puppet Agent..."

# Install Chrome
Write-Host "Installing Google Chrome Browser"
chocolatey install googlechrome --yes --force

# Install Notepad++
Write-Host "Installing Notepad++"
chocolatey install notepadplusplus --yes --force

# Install Sysinternals.
Write-Host "Installing Sysinternal Tools"
chocolatey install procexp --yes --force
chocolatey install procmon --yes --force
chocolatey install pstools --yes --force

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
