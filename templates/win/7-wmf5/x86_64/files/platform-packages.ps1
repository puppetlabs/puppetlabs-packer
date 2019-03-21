
. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-7 Package Customisation"

# WMF5 requires .Net 4.5.2 as a min, so install latest .dotnet here and now.
Install-DotNetLatest
if (Test-PendingReboot) {
  Invoke-Reboot
}

if (-not (Test-Path "$PackerLogs\KB2852386.installed"))
{
  # Install the WinSxS cleanup patch
  Write-Output "Installing Windows Update Cleanup Hotfix KB2852386"
  Install_Win_Patch -PatchUrl "https://artifactory.delivery.puppetlabs.net/artifactory/generic/iso/windows/win-2008r2-msu/Windows6.1-KB2852386-v2-x64.msu"
  Touch-File "$PackerLogs\KB2852386.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

if (-not (Test-Path "$PackerLogs\WMF5.installed"))
{
  # Install WMF 5 (Powershell)
  Write-Output "Installing WFM 5.1"
  Install_Win_Patch -PatchUrl "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/wmf5/Win7AndW2K8R2-KB3191566-x64.msu"
  Touch-File "$PackerLogs\WMF5.installed"
  Invoke-Reboot
}
