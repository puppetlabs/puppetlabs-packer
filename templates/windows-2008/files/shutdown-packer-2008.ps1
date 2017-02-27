# Windows-2008 special to do the shutdown.

$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

Write-Host "Packer Shutdown Script"

Write-Host "Disable WinRM"
Set-Service "WinRM" -StartupType Disabled

Write-Host "Initiating Shutdown"
shutdown /s /t 20 /f /d p:4:1 /c "Packer Shutdown"
