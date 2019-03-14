
. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-2008r2 Package Customisation"

if (-not (Test-Path "$PackerLogs\NET35.installed"))
{
  # Enable .Net 3.5 (needed for Puppet csc compiles)
  Write-Output "Enable .Net 3.5"
  DISM /Online /Enable-Feature /FeatureName:NetFx3
  # And add desktop experience for cleanmgr
  Write-Output "Enable Desktop-Experience"
  dism /online /enable-feature /FeatureName:DesktopExperience /featurename:InkSupport /norestart
  Touch-File "$PackerLogs\NET35.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

if (-not (Test-Path "$PackerLogs\KB2852386.installed"))
{
  # Install the WinSxS cleanup patch
  Write-Output "Installing Windows Update Cleanup Hotfix KB2852386"
  Install_Win_Patch -PatchUrl "https://artifactory.delivery.puppetlabs.net/artifactory/generic/iso/windows/win-2008r2-msu/Windows6.1-KB2852386-v2-x64.msu"
  Touch-File "$PackerLogs\KB2852386.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}
