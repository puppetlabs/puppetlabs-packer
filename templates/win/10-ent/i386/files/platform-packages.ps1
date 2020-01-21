
. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-10 Package Customisation"

# Flag to remove Apps packages and other nuisances
Touch-File "$PackerLogs\AppsPackageRemove.Required"

if (-not (Test-Path "$PackerLogs\KB4528759.installed"))
{
  Write-Output "Installing Windows Update SSU KB4528759"
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/secu/2020/01/windows10.0-kb4528759-x86_5ee4c5443a4d70dcf2399e1c2afe57f625e72b3d.msu"
  Touch-File "$PackerLogs\KB4528759.installed"
  Invoke-Reboot
}
