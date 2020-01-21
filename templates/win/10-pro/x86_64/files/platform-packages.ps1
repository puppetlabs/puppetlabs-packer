
. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-10 Package Customisationtemplates/windows-10/files/i386/platform-packages.ps1"

# Flag to remove Apps packages and other nuisances
Touch-File "$PackerLogs\AppsPackageRemove.Required"

if (-not (Test-Path "$PackerLogs\KB4528759.installed"))
{
  Write-Output "Installing Windows Update SSU KB4528759"
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/secu/2020/01/windows10.0-kb4528759-x64_c2d6639977986b927d0b9f1acf0fb203c38fc8c8.msu"
  Touch-File "$PackerLogs\KB4528759.installed"
  Invoke-Reboot
}
