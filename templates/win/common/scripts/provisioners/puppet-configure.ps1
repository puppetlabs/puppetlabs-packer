# Main script to run puppet to configure host.
# This script no longer runs under Boxstarter as the reboot sequence doesn't play well with packer once winrm is up
#

$ErrorActionPreference = "Stop"

. C:\Packer\Scripts\windows-env.ps1

if (Test-Path "$PackerLogs\Mock.Platform" ) {
  Write-Output "Test Platform Build - exiting"
  exit 0
}

Write-Output "Installing Puppet Agent..."
if ("$ARCH" -eq "x86") {
  $PuppetMSIUrl = "https://downloads.puppetlabs.com/windows/puppet-agent-x86-latest.msi"
} else {
  $PuppetMSIUrl = "https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi"
}

# Install Puppet Agent
Download-File "$PuppetMSIUrl" $PackerDownloads\puppet-agent.msi
Start-Process -Wait "msiexec" @SprocParms -ArgumentList "/i $PackerDownloads\puppet-agent.msi /qn /norestart PUPPET_AGENT_STARTUP_MODE=manual"
Write-Output "Installed Puppet Agent..."

# Pick up win-site.pp file from A: drive if present
# Manifest needs to be in $PackerPuppet for configuration to be picked up.
if ( Test-Path "$PackerConfig\win-site.pp") {
  Copy-Item "$PackerConfig\win-site.pp" "$PackerPuppet\win-site.pp"
}

# TODO don't think these are needed here so move them into puppet code if still needed.
Write-Output "Disabling Hibernation..."
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
  Write-Output "Found Modules directory $ModulesPath"
}
else {
  Write-Output "No Puppet files found at $PackerPuppet"
}

# Download and install listed FOrge modules if a relevant forge-modules.txt file is found
$ForgeMods = "$ModulesPath\forge-modules.txt"
If ((Test-Path -path $ForgeMods) -and ($ModulesPath -ne '')) {
  Get-Content -Path $ForgeMods | % {
    # Remove any comments first and trim line
    $line = $_
    if ($line.IndexOf('#') -gt -1) { $line = $line.Substring(0,$line.IndexOf('#')) }
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
      } ElseIf ($splitUp.Count -eq 2) {
        $moduleversion = $splitUp[1]
        Write-Output "Installing the $modulename Version $moduleversion module from the Forge..."
        $modveropt = "--version"
      } else {
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
          & $PuppetPath module install $modveropt $moduleversion --verbose --target-dir $ModulesPath $modulename
          $EC = $LASTEXITCODE
          if ($EC -ne 0) {throw "Module install failure"}
        } catch {
          Write-Output "Installing puppet module $modulename failed at attempt $attempt - sleep and retry"
          Start-Sleep -Seconds 10
          continue
        }

        Write-Output "Module $modulename installed"
        $ModuleLoaded = $true
        break

      } while ($Attempt -lt $MaxAttempts)
      if ( -not $ModuleLoaded ) {throw "Failed to download $modulename - aborting."}
    }
  }
}
else {
  Write-Output "No modules were required to be downloaded from the forge $ForgeMods"
}

# TODO What about custom facts?

Write-Output "Loading Default User hive to HKLM\DEFUSER..."
& reg load HKLM\DEFUSER C:\Users\Default\NTUSER.DAT

# Set "facts" that we need for the Puppet Run
$ENV:FACTER_modules_path         = "$ModulesPath"
$ENV:FACTER_build_date           = get-date -format "yyyy-MM-dd HH:mm zzz"
$ENV:FACTER_packer_sha           = $ENV:PackerSHA
$ENV:FACTER_packer_template_name = $ENV:PackerTemplateName
$ENV:FACTER_packer_template_type = $ENV:PackerTemplateType
# Pick Up user attributes as these could be localised.
$ENV:FACTER_administrator_sid     =  $WindowsAdminSID
$ENV:FACTER_administrator_grp_sid = "S-1-5-32-544"

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


# Loop through all Manifest Files in puppet base and process them
# Keep reapplying until no resources are modified, or MaxAttempts is hit
Write-Output "Puppet Manifest Processing Starting"
Get-ChildItem -Path $PackerPuppet -Filter '*.pp' | ? { -not $_.PSIsContainer } | % {
  $MaxAttempts = 20
  $Attempt = 1
  $Manifest = $_
  $AllDone = $false
  do {
    Write-Output "Applying $($Manifest.Name).  Attempt $Attempt of $MaxAttempts ..."

    & $PuppetPath apply ($Manifest.Fullname) "--modulepath=$ModulesPath" --verbose --detailed-exitcodes
    $EC = $LASTEXITCODE
    switch ($EC) {
      0 {
        Write-Output "$($Manifest.Name) completed and no resources were modified.  Can exit now"
        $AllDone = $true
        break
      }
      2 {
        Write-Output "$($Manifest.Name) completed but some resources were modified.  Will retry"
        break
      }
      default {
        Write-Output "$($Manifest.Name) failed with exit code $EC"
        throw "Puppet manifest $($Manifest.Name) failed with exit code $EC"
      }
    }
    $Attempt++
  } while ( -not $AllDone -and ($Attempt -lt $MaxAttempts) )
  if (-not $AllDone) { throw "Failed to converge $($Manifest.Name).  Max attempts exceeded"}
}
Write-Output "Puppet Manifest Processing Finished"

Write-Output "Unloading Default User hive from HKLM\DEFUSER..."
& reg unload HKLM\DEFUSER

# end
