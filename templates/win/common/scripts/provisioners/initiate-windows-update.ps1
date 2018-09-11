
# Initiate the Windows Update operation.

$ErrorActionPreference = 'Stop'

. C:\Packer\Scripts\windows-env.ps1

Write-Output "Setting up Windows Update"

# Important Pre-requisite right across the packer  including Windows Update.
if (-not (Test-Path "$PackerLogs\7zip.installed")) {
  # Download and install 7za now as its needed here and is useful going forward.
  $SevenZipInstaller = "7z1604-$ARCH.exe"
  Write-Output "Installing 7zip $SevenZipInstaller"
  Download-File "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/7zip/$SevenZipInstaller"  "$Env:TEMP\$SevenZipInstaller"
  Start-Process -Wait "$Env:TEMP\$SevenZipInstaller" @SprocParms -ArgumentList "/S"
  Touch-File "$PackerLogs\7zip.installed"
  Write-Output "7zip Installed"
}

if (-not (Test-Path "$PackerLogs\PSWindowsUpdate.installed")) {
  # Download and install PSWindows Update Modules.
  Download-File "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/pswindowsupdate/PSWindowsUpdate.1.6.1.1.zip" "$Env:TEMP/pswindowsupdate.zip"
  mkdir -Path "$Env:TEMP\PSWindowsUpdate"
  $zproc = Start-Process "$7zip" @SprocParms -ArgumentList "x $Env:TEMP/pswindowsupdate.zip -y -o$PackerStaging"
  $zproc.WaitForExit()
  Touch-File "$PackerLogs\PSWindowsUpdate.installed"
}

Write-Output "========== Initiating Windows Update ========"
Write-Output "========== This will take some time  ========"
Write-Output "========== a log and update report   ========"
Write-Output "========== will be given at the end  ========"
Write-Output "========== of the update cycle       ========"


$AdminUser = "Administrator"
$AdminPassword = "PackerAdmin"
Write-Output "Create Bootstrap Scheduled Task"
schtasks /create /tn PackerWinUpdate /rl HIGHEST /ru "$AdminUser" /RP "$AdminPassword" /IT /F /SC ONSTART /DELAY 0000:20 /TR 'cmd /c c:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Normal -ExecutionPolicy Bypass -NonInteractive -NoProfile -File C:\Packer\Scripts\packer-windows-update.ps1 >> C:\Packer\Logs\windows-update.log'

# Disable WinRM until further notice.
Set-Service "WinRM" -StartupType Disabled
