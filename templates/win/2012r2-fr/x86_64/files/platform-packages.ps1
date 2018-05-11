$ErrorActionPreference = "Stop"

. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-2012r2 French Package Customisation"

if (-not (Test-Path "$PackerLogs\DesktopExperience.installed"))
{
  # Enable Desktop experience to get cleanmgr
  Write-Output "Enable Desktop-Experience"
  Add-WindowsFeature Desktop-Experience
  Touch-File "$PackerLogs\DesktopExperience.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}
