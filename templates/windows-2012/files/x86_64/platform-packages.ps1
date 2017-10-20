$ErrorActionPreference = "Stop"

. A:\windows-env.ps1

Write-Host "Running Win-2012 Package Customisation"

if (-not (Test-Path "$PackerLogs\DesktopExperience.installed"))
{
  # Enable Desktop experience to get cleanmgr
  Write-Host "Enable Desktop-Experience"
  Add-WindowsFeature Desktop-Experience
  Touch-File "$PackerLogs\DesktopExperience.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

# Servicing Stack Patches that don't get slipstreamed properly to be installed.
if (-not (Test-Path "$PackerLogs\Win2012.Patches"))
{
  $patches = @(
    'http://download.windowsupdate.com/c/msdownload/update/software/updt/2015/04/windows8-rt-kb3003729-x64_e95e2c0534a7f3e8f51dd9bdb7d59e32f6d65612.msu',
    'http://download.windowsupdate.com/d/msdownload/update/software/updt/2015/09/windows8-rt-kb3096053-x64_930f557083e97c7e22e7da133e802afca4963d4f.msu',
    'http://download.windowsupdate.com/d/msdownload/update/software/crup/2016/06/windows8-rt-kb3173426-x64_ecf1b38d9e3cdf1eace07b9ddbf6f57c1c9d9309.msu'
  )
  $patches | % { Install_Win_Patch -PatchUrl $_ }

  Touch-File "$PackerLogs\Win2012.Patches"
  if (Test-PendingReboot) { Invoke-Reboot }
}
