$ErrorActionPreference = "Stop"

# Boxstarter options
$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

if (Test-PendingReboot){ Invoke-Reboot }

Write-BoxstarterMessage "Disabling Hiberation..."
Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateFileSizePercent' -Value 0
Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateEnabled' -Value 0

Write-BoxstarterMessage "Installing Puppet Agent..."
# TODO Don't use Chocolatey for this?
#  https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi
choco install puppet-agent -installArgs '"PUPPET_AGENT_STARTUP_MODE=manual"' -y

Write-BoxstarterMessage "Extracting Puppet archive..."
# %ChocolateyInstall%\Tools\7za.exe A:\PUPPET.ZIP to where?
# TODO investigate HTTP server in Packer

$TempPuppetModules = "$($ENV:TEMP)\packer-puppet"
$ModulesPath = ''
$SrcPuppetZip = "A:\Puppet.ZIP"
$PuppetPath = 'C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat'

# Cleanup any previous data
if (Test-Path -Path $TempPuppetModules) { Remove-Item -Path $TempPuppetModules -Recurse -Force -Confirm:$False | Out-Null}

# Extract out the Puppet.ZIP if it exists
if (Test-Path -Path $SrcPuppetZip) {
  Write-BoxstarterMessage "Extracting $SrcPuppetZip to $TempPuppetModules"
  $7zaexe = "$($ENV:ChocolateyInstall)\tools\7za.exe"
  & $7zaexe x -o"`"$TempPuppetModules`"" -y "$SrcPuppetZip"

  # Find the Modules Path
  $modPath = "$TempPuppetModules\modules"
  if (($ModulesPath -eq '') -and (Test-Path -Path $modPath)) {$ModulesPath = $modpath}
  $modPath = "$TempPuppetModules\puppet\modules"
  if (($ModulesPath -eq '') -and (Test-Path -Path $modPath)) {$ModulesPath = $modpath}
  # Throw if no Modules directory
  if ($ModulesPath -eq '') { Throw "No Modules Directory found in $SrcPuppetZip" }
  Write-BoxstarterMessage "Found Modules directory $ModulesPath"
}
else {
  Write-BoxstarterMessage "No Puppet Zip file found at $SrcPuppetZip"
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
Get-ChildItem -Path 'A:\' -Filter '*.pp' | ? { -not $_.PSIsContainer } | % {
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

Write-BoxStarterMessage "Unloading Default User hive from HKLM\DEFUSER..."
& reg unload HKLM\DEFUSER

Write-BoxstarterMessage "Uninstalling Puppet Agent..."
# TODO Don't use Chocolatey for this?
choco uninstall puppet-agent -uninstallargs '"REBOOT=ReallySuppress"' -y
& cmd.exe /C RD C:\ProgramData\PuppetLabs /s /q

Write-Host Staring CMD.exe
& cmd.exe /c Start cmd.exe
Read-Host "Press enter"

if (Test-PendingReboot) { Invoke-Reboot }

# Remove the pagefile
Write-BoxstarterMessage "Removing page file.  Recreates on next boot"
$pageFileMemoryKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $pageFileMemoryKey -Name PagingFiles -Value ""

# TODO Set Local Administrators password!

# TODO Apparently I need to setup autologon for Administrator.  I don't like this.  Need to figure out why

$enableArgs=@{Force=$true}
try {
 $command=Get-Command Enable-PSRemoting
  if($command.Parameters.Keys -contains "skipnetworkprofilecheck"){
      $enableArgs.skipnetworkprofilecheck=$true
  }
}
catch {
  $global:error.RemoveAt(0)
}
Enable-PSRemoting @enableArgs
Enable-WSManCredSSP -Force -Role Server
# NOTE - This is insecure but can be shored up in later customisation.  Required for Vagrant and other provisioning tools
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
Write-BoxstarterMessage "WinRM setup complete"

# TODO Remove Boxstarter?
# TODO Remove Chocolatey?