# Windows-2008 special to do the shutdown.


. C:\Packer\Scripts\windows-env.ps1

Write-Output "Packer Shutdown Script"

Write-Output "Disable WinRM"
Set-Service "WinRM" -StartupType Disabled

Write-Output "Initiating Shutdown"
shutdown /s /t 20 /f /d p:4:1 /c "Packer Shutdown"
