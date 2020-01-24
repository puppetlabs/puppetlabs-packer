
. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-2019 Package Customisation"

if (-not (Test-Path "$PackerLogs\KB4523204.installed"))
{
  Write-Output "Installing Windows Update SSU KB4523204"
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/11/windows10.0-kb4523204-x64_57098d9954748b2d7d767f73f60493bc592ff286.msu"
  Touch-File "$PackerLogs\KB4523204.installed"
  Invoke-Reboot
}
