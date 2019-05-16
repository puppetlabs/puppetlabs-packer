
. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-2016 Core Package Customisation"

if (-not (Test-Path "$PackerLogs\kb4500641.installed"))
{
  Write-Output "Installing Windows Update SSU kb4485447"
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/05/windows10.0-kb4500641-x64_66a086b2ae104c6b295b0da94500b85125a6a562.msu"
  Touch-File "$PackerLogs\kb4500641.installed"
  Invoke-Reboot
}

