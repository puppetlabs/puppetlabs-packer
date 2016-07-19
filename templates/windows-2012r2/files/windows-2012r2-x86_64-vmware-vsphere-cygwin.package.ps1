$ErrorActionPreference = "Stop"

# Boxstarter options
$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$true # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

if (Test-PendingReboot){ Invoke-Reboot }

Write-BoxstarterMessage "Disabling Hibernation..."
Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateFileSizePercent' -Value 0
Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateEnabled' -Value 0

# TODO intend to move this to the common windows environment file.

$PackerPuppet = "C:\Packer\puppet"
$ModulesPath = ''
$PuppetPath = 'C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat'

# Locate Packer Puppet Modules
if (Test-Path -Path $PackerPuppet) {
  # Find the Modules Path
  $modPath = "$PackerPuppet\modules"
  if (($ModulesPath -eq '') -and (Test-Path -Path $modPath)) {$ModulesPath = $modpath}
  $modPath = "$PackerPuppet\puppet\modules"
  if (($ModulesPath -eq '') -and (Test-Path -Path $modPath)) {$ModulesPath = $modpath}
  # Throw if no Modules directory
  if ($ModulesPath -eq '') { Throw "No Modules Directory found in $PackerPuppet" }
  Write-BoxstarterMessage "Found Modules directory $ModulesPath"
}
else {
  Write-BoxstarterMessage "No Puppet files found at $PackerPuppet"
}

# Download and install listed FOrge modules if a relevant forge-modules.txt file is found
$ForgeMods = "$ModulesPath\forge-modules.txt"
If ((Test-Path -path $ForgeMods) -and ($ModulesPath -ne '')) {
  Get-Content -Path $ForgeMods | % {
    $modulename = $_
    if ($modulename.IndexOf('#') -gt -1) { $modulename = $modulename.Substring(0,$modulename.IndexOf('#')) }
    $modulename = $modulename.Trim()
    if ($modulename -ne '') {
      Write-BoxstarterMessage "Installing the $modulename module from the Forge..."

      & $PuppetPath module install "$modulename" --verbose --target-dir $ModulesPath
      $EC = $LASTEXITCODE
      if ($EC -ne 0) {
        Write-BoxstarterMessage "Installing puppet module $modulename returned exit code $EC"
        Throw "Installing puppet module $modulename returned exit code $EC"
      }
      else
      {
        Write-BoxstarterMessage "Module $modulename installed"
      }
    }
  }
}
else {
  Write-BoxstarterMessage "No modules were required to be downloaded from the forge $ForgeMods"
}

# TODO What about custom facts?

Write-BoxStarterMessage "Loading Default User hive to HKLM\DEFUSER..."
& reg load HKLM\DEFUSER C:\Users\Default\NTUSER.DAT

# Loop through all Manifest Files in A:\ and process them
# Keep reapplying until no resources are modified, or MaxAttempts is hit
Write-BoxStarterMessage "Puppet Manifest Processing Starting"
Get-ChildItem -Path $PackerPuppet -Filter '*.pp' | ? { -not $_.PSIsContainer } | % {
  $MaxAttempts = 20
  $Attempt = 1
  $Manifest = $_
  $AllDone = $false
  do {
    Write-BoxstarterMessage "Applying $($Manifest.Name).  Attempt $Attempt of $MaxAttempts ..."

    & $PuppetPath apply ($Manifest.Fullname) "--modulepath=$ModulesPath" --verbose --detailed-exitcodes
    $EC = $LASTEXITCODE
    switch ($EC) {
      0 {
        Write-BoxstarterMessage "$($Manifest.Name) completed and no resources were modified.  Can exit now"
        $AllDone = $true
        break
      }
      2 {
        Write-BoxstarterMessage "$($Manifest.Name) completed but some resources were modified.  Will retry"
        if (Test-PendingReboot) { Invoke-Reboot }
        break
      }
      default {
        Write-BoxstarterMessage "$($Manifest.Name) failed with exit code $EC"
        throw "Puppet manifest $($Manifest.Name) failed with exit code $EC"
      }
    }
    $Attempt++
  } while ( -not $AllDone -and ($Attempt -lt $MaxAttempts) )
  if (-not $AllDone) { throw "Failed to converge $($Manifest.Name).  Max attempts exceeded"}
}
Write-BoxStarterMessage "Puppet Manifest Processing Finished"

Write-BoxStarterMessage "Unloading Default User hive from HKLM\DEFUSER..."
& reg unload HKLM\DEFUSER

Write-BoxStarterMessage "Test for Reboot....."
if (Test-PendingReboot) { Invoke-Reboot }

Write-BoxStarterMessage "Other Stuff......."
# Some other quick win settings provided by Boxstarter

#Disable UAC for Windows-2012
Disable-UAC

# Enable Remote Desktop (with reduce authentication resetting here again)
Enable-RemoteDesktop -DoNotRequireUserLevelAuthentication

# TODO May need to add some ps-remote/winrm configuration here
