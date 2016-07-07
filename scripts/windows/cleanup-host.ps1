# Cleanup tasks to ready this machine for production.

$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1


Write-Host "Uninstalling Puppet Agent..."
Start-Process -Wait "msiexec" -ArgumentList "/x C:\Packer\Downloads\puppet-agent.msi /qn /norestart PUPPET_AGENT_STARTUP_MODE=manual"

# TODO Remove Boxstarter?
# TODO Remove Chocolatey?


# Remove Directories

cmd.exe /C RD C:\ProgramData\PuppetLabs /s /q

# Remove the pagefile
Write-BoxstarterMessage "Removing page file.  Recreates on next boot"
$pageFileMemoryKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $pageFileMemoryKey -Name PagingFiles -Value ""


# Run Clean disk.
