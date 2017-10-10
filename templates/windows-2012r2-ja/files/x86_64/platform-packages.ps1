$ErrorActionPreference = "Stop"

. A:\windows-env.ps1

Write-Host "Running Win-2012r2 JA Package Customisation"

if (-not (Test-Path "$PackerLogs\DesktopExperience.installed"))
{
  # Enable Desktop experience to get cleanmgr
  Write-Host "Enable Desktop-Experience"
  Add-WindowsFeature Desktop-Experience
  Touch-File "$PackerLogs\DesktopExperience.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}
