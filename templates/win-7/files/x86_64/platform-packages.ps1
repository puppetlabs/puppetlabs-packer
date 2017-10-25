$ErrorActionPreference = "Stop"

. A:\windows-env.ps1

Write-Host "Running Win-7 Package Customisation"

if (-not (Test-Path "$PackerLogs\KB2852386.installed"))
{
  # Install the WinSxS cleanup patch
  Write-Host "Installing Windows Update Cleanup Hotfix KB2852386"
  Install_Win_Patch -PatchUrl "http://osmirror.delivery.puppetlabs.net/iso/windows/win-2008r2-msu/Windows6.1-KB2852386-v2-x64.msu"
  Touch-File "$PackerLogs\KB2852386.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}
