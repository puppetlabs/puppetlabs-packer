$ErrorActionPreference = "Stop"

. C:\Packer\Scripts\windows-env.ps1

Write-Host "Running Win-2016 Hyperv Package Customisation"

# Enable Hyperv

if (-not (Test-Path "$PackerLogs\HyperV.installed"))
{
    Write-Host "Installing HyperV"
    Install-WindowsFeature -Name Hyper-V -IncludeManagementTools 

    Touch-File "$PackerLogs\HyperV.installed"
    Invoke-Reboot
}
