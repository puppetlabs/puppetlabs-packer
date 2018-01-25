$ErrorActionPreference = "Stop"

. A:\windows-env.ps1

Write-Host "Running Win-10 Package Customisation"

# Remove Store/Apps packages that break sysprep
Remove-AppsPackages
