$ErrorActionPreference = "Stop"

. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-2016 Hyperv Package Customisation"

# Enable Hyperv

if (-not (Test-Path "$PackerLogs\HyperV.installed"))
{
    Write-Output "Installing HyperV"
    Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Verbose

    Touch-File "$PackerLogs\HyperV.installed"
    Invoke-Reboot
}

if (-not (Test-Path "$PackerLogs\Containers.installed"))
{
    Write-Output "Enabling Containers Feature"
    Install-WindowsFeature -Name Containers  -Verbose

    Touch-File "$PackerLogs\Containers.installed"
    Invoke-Reboot
}
