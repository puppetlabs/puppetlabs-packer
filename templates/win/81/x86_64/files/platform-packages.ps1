
. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-8.1 Package Customisation"

# Flag to remove Apps packages and other nuisances
Touch-File "$PackerLogs\AppsPackageRemove.Required"
