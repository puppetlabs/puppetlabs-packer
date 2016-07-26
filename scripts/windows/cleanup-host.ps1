# Cleanup tasks to ready this machine for production.

$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1


Write-Host "Uninstalling Puppet Agent..."
choco uninstall puppet-agent --yes

# Remove Boxstarter
Write-Host "Uninstalling boxstarter..."
choco uninstall boxstarter --yes

# TODO Remove Chocolatey - probably not as it will poleaxe Sysinternals?
# Need to discuss with Rob - suspect ok to leave on machine.

# Remove Directories

cmd.exe /C RD C:\ProgramData\PuppetLabs /s /q

# Remove the pagefile
Write-Host "Removing page file.  Recreates on next boot"
$pageFileMemoryKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $pageFileMemoryKey -Name PagingFiles -Value ""


# Run Clean disk.
