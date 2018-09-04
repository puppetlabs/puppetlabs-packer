$ErrorActionPreference = "Stop"

. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-2019 Mock Platform Generation"

# Create the Mock Platform File.

Touch-File "$PackerLogs\Mock.Platform"
