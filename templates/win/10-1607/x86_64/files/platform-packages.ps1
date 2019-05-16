
. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-10 Package Customisationtemplates/windows-10/files/i386/platform-packages.ps1"

if (-not (Test-Path "$PackerLogs\kb4485447.installed"))
{
  Write-Output "Installing Windows Update SSU kb4485447"
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/05/windows10.0-kb4498947-x64_97b6d1b006cd564854f39739d4fc23e3a72373d7.msu"
  Touch-File "$PackerLogs\kb4485447.installed"
  Invoke-Reboot
}

# Flag to remove Apps packages and other nuisances
Touch-File "$PackerLogs\AppsPackageRemove.Required"
