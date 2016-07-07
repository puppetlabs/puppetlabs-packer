#
# Install the various packages that we need to get this machine up on the air as a build/test box
#

$ErrorActionPreference = 'Stop'

$scriptDirectory = (Split-Path -parent $MyInvocation.MyCommand.Definition);
. A:\windows-env.ps1


Write-Host "Installing Puppet Agent..."

(new-object net.webclient).DownloadFile('https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi',"C:\Packer\Downloads\puppet-agent.msi")

Start-Process -Wait "msiexec" -ArgumentList "/i C:\Packer\Downloads\puppet-agent.msi /qn /norestart PUPPET_AGENT_STARTUP_MODE=manual"
Write-Host "Installed Puppet Agent..."
