# Main script to run puppet to configure host.
# This script no longer runs under Boxstarter as the reboot sequence doesn't play well with packer once winrm is up
#
$ErrorActionPreference = "Stop"

. A:\windows-env.ps1

# TODO don't think these are needed here so move them into puppet code if still needed.
Write-Host "Disabling Hibernation..."
Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateFileSizePercent' -Value 0
Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateEnabled' -Value 0

# Locate Packer Puppet Modules
if (Test-Path -Path $PackerPuppet) {
  # Find the Modules Path
  $modPath = "$PackerPuppet\modules"
  if (($ModulesPath -eq '') -and (Test-Path -Path $modPath)) {$ModulesPath = $modpath}
  $modPath = "$PackerPuppet\puppet\modules"
  if (($ModulesPath -eq '') -and (Test-Path -Path $modPath)) {$ModulesPath = $modpath}
  # Throw if no Modules directory
  if ($ModulesPath -eq '') { Throw "No Modules Directory found in $PackerPuppet" }
  Write-Host "Found Modules directory $ModulesPath"
}
else {
  Write-Host "No Puppet files found at $PackerPuppet"
}

# Download and install listed FOrge modules if a relevant forge-modules.txt file is found
$ForgeMods = "$ModulesPath\forge-modules.txt"
If ((Test-Path -path $ForgeMods) -and ($ModulesPath -ne '')) {
  Get-Content -Path $ForgeMods | % {
    $modulename = $_
    if ($modulename.IndexOf('#') -gt -1) { $modulename = $modulename.Substring(0,$modulename.IndexOf('#')) }
    $modulename = $modulename.Trim()
    if ($modulename -ne '') {
      Write-Host "Installing the $modulename module from the Forge..."

      # Using Loop here to improve resiliency.
      # BITS (or other service) may not have started, so allow for module install error here.

      $MaxAttempts = 20
      $Attempt = 0
      $ModuleLoaded = $false
      do {
        $Attempt++

        try {
          & $PuppetPath module install "$modulename" --verbose --target-dir $ModulesPath
          $EC = $LASTEXITCODE
          if ($EC -ne 0) {throw "Module install failure"}
        } catch {
          Write-Host "Installing puppet module $modulename failed at attempt $attempt - sleep and retry"
          Start-Sleep -Seconds 10
          continue
        }

        Write-Host "Module $modulename installed"
        $ModuleLoaded = $true
        break

      } while ($Attempt -lt $MaxAttempts)
      if ( -not $ModuleLoaded ) {throw "Failed to download $modulename - aborting."}
    }
  }
}
else {
  Write-Host "No modules were required to be downloaded from the forge $ForgeMods"
}

# TODO What about custom facts?

Write-Host "Loading Default User hive to HKLM\DEFUSER..."
& reg load HKLM\DEFUSER C:\Users\Default\NTUSER.DAT

# Loop through all Manifest Files in A:\ and process them
# Keep reapplying until no resources are modified, or MaxAttempts is hit
Write-Host "Puppet Manifest Processing Starting"
Get-ChildItem -Path $PackerPuppet -Filter '*.pp' | ? { -not $_.PSIsContainer } | % {
  $MaxAttempts = 20
  $Attempt = 1
  $Manifest = $_
  $AllDone = $false
  do {
    Write-Host "Applying $($Manifest.Name).  Attempt $Attempt of $MaxAttempts ..."

    & $PuppetPath apply ($Manifest.Fullname) "--modulepath=$ModulesPath" --verbose --detailed-exitcodes
    $EC = $LASTEXITCODE
    switch ($EC) {
      0 {
        Write-Host "$($Manifest.Name) completed and no resources were modified.  Can exit now"
        $AllDone = $true
        break
      }
      2 {
        Write-Host "$($Manifest.Name) completed but some resources were modified.  Will retry"
        break
      }
      default {
        Write-Host "$($Manifest.Name) failed with exit code $EC"
        throw "Puppet manifest $($Manifest.Name) failed with exit code $EC"
      }
    }
    $Attempt++
  } while ( -not $AllDone -and ($Attempt -lt $MaxAttempts) )
  if (-not $AllDone) { throw "Failed to converge $($Manifest.Name).  Max attempts exceeded"}
}
Write-Host "Puppet Manifest Processing Finished"

Write-Host "Unloading Default User hive from HKLM\DEFUSER..."
& reg unload HKLM\DEFUSER

# end
