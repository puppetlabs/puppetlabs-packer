
. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-10 Package Customisationtemplates/windows-10/files/i386/platform-packages.ps1"

# Flag to remove Apps packages and other nuisances
Touch-File "$PackerLogs\AppsPackageRemove.Required"

if (-not (Test-Path "$PackerLogs\kb4035632.installed"))
{
  Write-Output "Installing Windows Update SSU kb4035632"
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/crup/2017/08/windows10.0-kb4035632-x64_ea26f11d518e5e363fe9681b290a56a6afe15a81.msu"
  Touch-File "$PackerLogs\kb4035632.installed"
  Invoke-Reboot
}

