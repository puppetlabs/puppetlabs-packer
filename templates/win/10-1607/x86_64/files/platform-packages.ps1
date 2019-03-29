
. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-10 Package Customisationtemplates/windows-10/files/i386/platform-packages.ps1"

if (-not (Test-Path "$PackerLogs\kb4132216.installed"))
{
  Write-Output "Installing Windows Update SSU kb4132216"
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/c/msdownload/update/software/crup/2018/05/windows10.0-kb4132216-x64_9cbeb1024166bdeceff90cd564714e1dcd01296e.msu"
  Touch-File "$PackerLogs\kb4132216.installed"
  if (Test-PendingReboot) {Invoke-Reboot}
}

if (-not (Test-Path "$PackerLogs\kb4049065.installed"))
{
  Write-Output "Installing Windows Update SSU kb4049065"
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/crup/2017/10/windows10.0-kb4049065-x64_f92abbe03d011154d52cf13be7fb60e2c6feb35b.msu"
  Touch-File "$PackerLogs\kb4049065.installed"
  if (Test-PendingReboot) {Invoke-Reboot}
}

if (-not (Test-Path "$PackerLogs\kb4465659.installed"))
{
  Write-Output "Installing Windows Update SSU kb4465659"
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/11/windows10.0-kb4465659-x64_af8e00c5ba5117880cbc346278c7742a6efa6db1.msu"
  Touch-File "$PackerLogs\kb4465659.installed"
  if (Test-PendingReboot) {Invoke-Reboot}
}

if (-not (Test-Path "$PackerLogs\kb4485447.installed"))
{
  Write-Output "Installing Windows Update SSU kb4485447"
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/02/windows10.0-kb4485447-x64_e9334a6f18fa0b63c95cd62930a058a51bba9a14.msu"
  Touch-File "$PackerLogs\kb4485447.installed"
  if (Test-PendingReboot) {Invoke-Reboot}
}

# Flag to remove Apps packages and other nuisances
Touch-File "$PackerLogs\AppsPackageRemove.Required"
