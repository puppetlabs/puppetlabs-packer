$ErrorActionPreference = "Stop"

. A:\windows-env.ps1



if (-not (Test-Path "A:\DesktopExperience.installed"))
{
  # Enable Desktop experience to get cleanmgr
  Write-Host "Enable Desktop-Experience"
  Add-WindowsFeature Desktop-Experience
  Touch-File "A:\DesktopExperience.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}
