$ErrorActionPreference = "Stop"

. A:\windows-env.ps1

Write-Host "Running Win-10 Package Customisation"

# Remove Win-10 packages that break sysprep
Remove-Win10Packages
