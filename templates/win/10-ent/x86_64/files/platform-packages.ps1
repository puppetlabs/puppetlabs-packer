$ErrorActionPreference = "Stop"

. C:\Packer\Scripts\windows-env.ps1

Write-Host 'Running Win-10 Package Customisation templates/windows-10/files/i386/platform-packages.ps1'

# Flag to remove Apps packages and other nuisances
Touch-File "$PackerLogs\AppsPackageRemove.Required"
