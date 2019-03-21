<#
  .SYNOPSIS
    Puppet Configuration Script - with reboot capability.
  .DESCRIPTION
    This script is run as a scheduled task and supports reboot similar to that for the Windows Update Cycle.
    This allows for puppet configuration actions that require a reboot.
#>

. C:\Packer\Scripts\windows-env.ps1

$rundate = Get-Date
write-output "Script: packer-puppet-configure.ps1 Starting at: $rundate"

# Setup Counter file so that we can persist the puppet counter across
# reboots of the host.
$PuppetCounterFile = "$PackerLogs\Puppet.Counter"

if (-not (Test-Path "$PuppetCounterFile")) {
  New-Item -Path $PuppetCounterFile
  Set-Content -Path $PuppetCounterFile "0"
}

# TODO What about custom facts?

Write-Output "Loading Default User hive to HKLM\DEFUSER..."
& reg load HKLM\DEFUSER C:\Users\Default\NTUSER.DAT

# Set "facts" that we need for the Puppet Run
$ENV:FACTER_modules_path         = "$PuppetModulesPath"
$ENV:FACTER_packer_downloads     = "$PackerDownloads"
$ENV:FACTER_packer_config        = "$PackerConfig"
$ENV:FACTER_sysinternals         = "$SysInternals"
# Pick Up user attributes as these could be localised.
$ENV:FACTER_administrator_sid     =  $WindowsAdminSID
$ENV:FACTER_administrator_grp_sid = "S-1-5-32-544"
$ENV:FACTER_psversionmajor        = $PSVersionTable.PSVersion.Major

# Chrome root needs arch detection as under x86 on 64 bit boxen
if ("$ARCH" -eq "x86") {
  $ENV:FACTER_chrome_root        = "$ENV:ProgramFiles\Google\Chrome"
} else {
  $ENV:FACTER_chrome_root        = "$ENV:ProgramFiles `(x86`)\Google\Chrome"
}
If ( $WindowsServerCore ) {
  $ENV:FACTER_windows_install_option = "Core"
}
else {
  $ENV:FACTER_windows_install_option = "Normal"
}

# Puppet run loop - use the Manifest in the Config Directory and run Puppet as many times up
# to MaxAttempts until no further resources are modified.
# This loop allows for reboot, either as a direct puppet action (using Reboot module) or if
# any pending reboots are detected at the end of a run.
Try {
  Write-Output "Puppet Manifest Processing Starting"
  $Manifest = Get-Item -Path "$PackerPuppet\win-site.pp"
  [int]$MaxAttempts = 20
  [int]$AttemptCounter = Get-Content -Path $PuppetCounterFile
  $AllDone = $false
  $PuppetSucceeded = $false
  do {
    # Increment and Persist the AttemptCounter
    $AttemptCounter++
    Set-Content -Path $PuppetCounterFile "$AttemptCounter"
    Write-Output "Applying $($Manifest.Name).  Attempt $AttemptCounter of $MaxAttempts ..."

    & $PuppetPath apply ($Manifest.Fullname) "--hiera_config=$PuppetModulesPath\hiera.yaml" "--modulepath=$PuppetModulesPath" --verbose --detailed-exitcodes
    $EC = $LASTEXITCODE
    switch ($EC) {
      1 {
        # This is regarded as a hard failure and will cause an exit.
        Write-Output "$($Manifest.Name) failed with exit code $EC"
        Write-Error "Puppet manifest $($Manifest.Name) failed with exit code $EC"
        $AllDone = $true
        break
      }
      0 {
        Write-Output "$($Manifest.Name) completed and no resources were modified.  Can exit now"
        $AllDone = $true
        $PuppetSucceeded = $true
        break
      }
      2 {
        Write-Output "$($Manifest.Name) completed but some resources were modified.  Will retry"
        break
      }
      default {
        Write-Output "$($Manifest.Name) failed with exit code $EC"
        Write-Error "Puppet manifest $($Manifest.Name) failed with exit code $EC"
        # Let this re-run up to max-attempts.
      }
    }
    # Test Pending Reboot here 
    if (Test-PendingReboot) { 
      Write-Output "Changes in Puppet run require a reboot"
      Invoke-Reboot 
    }
  } while ( -not $AllDone -and ($AttemptCounter -lt $MaxAttempts) )

  if ($AllDone) {
    if ($PuppetSucceeded) {
      # The "Succeeded" marker is checked in the later puppet/Pester test run which
      # tests for the presence of the file and fails if the run if its not there.
      Write-Output "Puppet Run succeeded - marking as such"
      Touch-File "$PackerLogs/Puppet.succeeded"
    }
    else {
      # Puppet run failed for some reason - allow exit so that log can be printed.
      # Run will be stopped later because success file doesn't exist.
      Write-Output "Error with $($Manifest.Name) - Exiting."
    }
  }
  else {
    Write-Error "Failed to converge $($Manifest.Name).  Max attempts exceeded"
  }
} Catch {
  # This catch to pick up any puppet or other errors not trapped above.
  # All other errors are repored using the Puppet Run.
  Write-Error "Error running puppet for $($Manifest.Name). Error trapped."
}

Write-Output "Puppet Manifest Processing Finished"

Write-Output "Unloading Default User hive from HKLM\DEFUSER..."
& reg unload HKLM\DEFUSER

# Puppet Configure Cycle complete - delete this task.
Write-Output "Deleting Bootstrap Scheduled Task"
schtasks /Delete /tn PuppetConfigure /F

# Enable WinRM so Packer control resumes immediately.
# This differs from the windows update cycle in that the need for reboot
# will already have been detected earlier, so no need for an additional.
Write-Output "Enable and restart Winrm"
Set-Service "WinRM" -StartupType Automatic -Status Running
Write-Output "WinRM Enabled - Exiting script"

# end
