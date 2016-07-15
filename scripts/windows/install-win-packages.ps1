#
# Install the various packages that we need to get this machine up on the air as a build/test box
#

$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

Write-Host "Installing Puppet Agent..."
chocolatey install puppet-agent --yes --force
Write-Host "Installed Puppet Agent..."

# Install Chrome
Write-Host "Installing Google Chrome Browser"
chocolatey install googlechrome --yes --force

# Install Notepad++
Write-Host "Installing Notepad++"
chocolatey install notepadplusplus --yes --force

# Install Sysinternals.
Write-Host "Installing Sysinternal Tools"
chocolatey install procexp --yes --force
chocolatey install procmon --yes --force
chocolatey install pstools --yes --force
