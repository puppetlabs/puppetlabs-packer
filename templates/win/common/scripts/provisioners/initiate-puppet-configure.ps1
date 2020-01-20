
<#
  .SYNOPSIS
    Initiate the Puppet Configuration Run
  .DESCRIPTION
    Create a scheduled task to start the puppet run.
    Disable WinRm and start the reboot sequence.
    This is run as a reboot sequence.
#>

$ErrorActionPreference = 'Stop'

. C:\Packer\Scripts\windows-env.ps1

Write-Output "Setting up for Puppet Configuration"

Write-Output "Installing Puppet Agent..."
if ("$ARCH" -eq "x86") {
  $PuppetMSIUrl = "https://downloads.puppetlabs.com/windows/puppet6/puppet-agent-x86-latest.msi"
}
else {
  $PuppetMSIUrl = "https://downloads.puppetlabs.com/windows/puppet6/puppet-agent-x64-latest.msi"
}
Download-File "$PuppetMSIUrl" $PackerDownloads\puppet-agent.msi

Start-Process -Wait "msiexec" @SprocParms -ArgumentList "/i $PackerDownloads\puppet-agent.msi /qn /norestart PUPPET_AGENT_STARTUP_MODE=manual"
Write-Output "Installed Puppet Agent..."

# Pick up win-site.pp file from A: drive if present
# Manifest needs to be in $PackerPuppet for configuration to be picked up.
if ( Test-Path "$PackerConfig\win-site.pp") {
  Write-Output "Copying Site Manifest to $PackerPuppet"
  Copy-Item -Verbose "$PackerConfig\win-site.pp" "$PackerPuppet\win-site.pp"
}

try {
  # Download and install listed FOrge modules if a relevant forge-modules.txt file is found
  $ForgeMods = "$PuppetModulesPath\forge-modules.txt"
  If ((Test-Path -path $ForgeMods) ) {
    Get-Content -Path $ForgeMods | ForEach-Object {
      # Remove any comments first and trim line
      $line = $_
      if ($line.IndexOf('#') -gt -1) { $line = $line.Substring(0, $line.IndexOf('#')) }
      $line = $line.Trim()
      $splitUp = $line -split "\s+"
      $modulename = $splitUp[0]
      if ($modulename -ne '') {
        # Check to see if Version is specified.
        # NOTE - splatting would be preferable here, but doesn't work as puppet doesn't like the
        # colons in the splatted output, so stuck with an inelegant way of specifying version options.
        if ($splitUp.Count -eq 1) {
            Write-Output "Installing the $modulename (latest version) module from the Forge..."
            $moduleversion = ""
            $modveropt = ""
        }
        ElseIf ($splitUp.Count -eq 2) {
            $moduleversion = $splitUp[1]
            Write-Output "Installing the $modulename Version $moduleversion module from the Forge..."
            $modveropt = "--version"
        }
        else {
            throw "Invalid Modules definition line: $_"
        }

        # Using Loop here to improve resiliency.
        # BITS (or other service) may not have started, so allow for module install error here.

        $MaxAttempts = 20
        $Attempt = 0
        $ModuleLoaded = $false
        do {
          $Attempt++

          try {
            & $PuppetPath module install $modveropt $moduleversion --verbose --target-dir $PuppetModulesPath $modulename
            $EC = $LASTEXITCODE
            if ($EC -ne 0) {
              throw "Module install failure"
            }
          }
          catch {
            Write-Output "Installing puppet module $modulename failed at attempt $attempt - sleep and retry"
            Start-Sleep -Seconds 10
            continue
          }

          Write-Output "Module $modulename installed"
          $ModuleLoaded = $true
          break

        } while ($Attempt -lt $MaxAttempts)
        if ( -not $ModuleLoaded ) {
          throw "Failed to download $modulename - aborting."
        }
      }
    }
  }
  else {
    Write-Output "No modules were required to be downloaded from the forge $ForgeMods"
  }
} Catch {
  Write-Output "Failed to load Puppet Modules - aborting"
  Exit 1
}

Write-Output "========== Initiating Puppet Update This will take some time                    ========"
Write-Output "========== A log and update report will be given at the end of the update cycle ========"

# Need to pick up Admin Username/Password from Environment for sched task

Write-Output "Create Bootstrap Scheduled Task with $($PackerBuildParams.packer.admin_username)"
schtasks /create /tn PuppetConfigure /rl HIGHEST /ru "$($PackerBuildParams.packer.admin_username)" /RP "$($PackerBuildParams.packer.admin_password)" /IT /F /SC ONSTART /DELAY 0000:50 /TR 'cmd /c c:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Normal -ExecutionPolicy Bypass -NonInteractive -NoProfile -File C:\Packer\Scripts\puppet-configure.ps1 >> C:\Packer\Logs\puppet.log 2>&1'

# Disable WinRM until further notice.
Set-Service "WinRM" -StartupType Disabled
