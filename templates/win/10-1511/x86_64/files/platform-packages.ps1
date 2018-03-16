$ErrorActionPreference = "Stop"

. C:\Packer\Scripts\windows-env.ps1

Write-Host "Running Win-10 Package Customisationtemplates/windows-10/files/i386/platform-packages.ps1"

# Remove Store/Apps packages that break sysprep
Remove-AppsPackages
