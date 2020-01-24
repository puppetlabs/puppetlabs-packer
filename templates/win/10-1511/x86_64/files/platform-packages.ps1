
. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-10 Package Customisationtemplates/windows-10/files/i386/platform-packages.ps1"

# Flag to remove Apps packages and other nuisances
Touch-File "$PackerLogs\AppsPackageRemove.Required"

# This is a hack - but it works to get the windows update working - as in applying a recent CU as an update.
if (-not (Test-Path "$PackerLogs\kb4524153.installed"))
{
  Write-Output "Installing Windows Update SSU kb4524153"
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/09/windows10.0-kb4524153-x64_135d6f3ec9e9bb3a5e74ef669837166a08d7767f.msu"
  Touch-File "$PackerLogs\kb4524153.installed"
  Invoke-Reboot
}

if (-not (Test-Path "$PackerLogs\kb4523200.installed"))
{
  Write-Output "Installing Windows Update SSU kb4523200"
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/11/windows10.0-kb4523200-x64_8b9d9f7930dee5a052981864b86025ac832c2b21.msu"
  Touch-File "$PackerLogs\kb4523200.installed"
  Invoke-Reboot
}
