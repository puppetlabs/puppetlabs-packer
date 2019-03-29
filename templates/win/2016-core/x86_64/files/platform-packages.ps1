
. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-2016 Core Package Customisation"

if (-not (Test-Path "$PackerLogs\kb4485447.installed"))
{
  Write-Output "Installing Windows Update SSU kb4485447"
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/02/windows10.0-kb4485447-x64_e9334a6f18fa0b63c95cd62930a058a51bba9a14.msu"
  Touch-File "$PackerLogs\kb4485447.installed"
  Invoke-Reboot
}
