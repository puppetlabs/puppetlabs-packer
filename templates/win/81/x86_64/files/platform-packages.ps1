$ErrorActionPreference = "Stop"

. C:\Packer\Scripts\windows-env.ps1

Write-Host "Running Win-8.1 Package Customisation"

# Remove Store/Apps packages that break sysprep
Remove-AppsPackages
