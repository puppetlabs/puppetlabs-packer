#
# Install the various packages that we need to get this machine up on the air as a build/test box
#

$ErrorActionPreference = 'Stop'

. C:\Packer\Scripts\windows-env.ps1

# Install Sysinternals - to special tools directory as we may want to remove chocolatey
Write-Output "Installing Sysinternal Tools"
$SysInternalsTools = @(
  'ProcessExplorer', # https://download.sysinternals.com/files/ProcessExplorer.zip
  'ProcessMonitor',  # https://download.sysinternals.com/files/ProcessMonitor.zip
  'PSTools',         # https://download.sysinternals.com/files/PSTools.zip
  'BGInfo',          # https://download.sysinternals.com/files/BGInfo.zip
  'AutoLogon'        # https://download.sysinternals.com/files/AutoLogon.zip
)
$SysInternalsTools | ForEach-Object {
  Download-File https://download.sysinternals.com/files/$_.zip $PackerDownloads\$_.zip
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
