
. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-7 Package Customisation"

if (-not (Test-Path "$PackerLogs\KB2852386.installed"))
{
  # Install the WinSxS cleanup patch
  Write-Output "Installing Windows Update Cleanup Hotfix KB2852386"
  Install_Win_Patch -PatchUrl "https://artifactory.delivery.puppetlabs.net/artifactory/generic/iso/windows/win-2008r2-msu/Windows6.1-KB2852386-v2-x64.msu"
  Touch-File "$PackerLogs\KB2852386.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}
