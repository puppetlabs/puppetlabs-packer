# Cleanup tasks to ready this machine for production.

$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

$SpaceAtStart = [Math]::Round( ((Get-WmiObject win32_logicaldisk | where { $_.DeviceID -eq $env:SystemDrive }).FreeSpace)/1GB, 2)

Write-Host "Uninstalling Puppet Agent..."
Start-Process -Wait "msiexec" -ArgumentList "/x $PackerDownloads\puppet-agent.msi /qn /norestart"

# Remove Boxstarter
Write-Host "Uninstalling boxstarter..."
choco uninstall boxstarter --yes

# Remove Chocolatey - using instructions at https://chocolatey.org/docs/uninstallation
Write-Host "Uninstalling Chocolatey and all its bits..."

Remove-Item -Recurse -Force "$env:ChocolateyInstall"
[System.Text.RegularExpressions.Regex]::Replace( `
[Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment').GetValue('PATH', '',  `
[Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString(),  `
[System.Text.RegularExpressions.Regex]::Escape("$env:ChocolateyInstall\bin") + '(?>;)?', '', `
[System.Text.RegularExpressions.RegexOptions]::IgnoreCase) | `
%{[System.Environment]::SetEnvironmentVariable('PATH', $_, 'User')}
[System.Text.RegularExpressions.Regex]::Replace( `
[Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment\').GetValue('PATH', '', `
[Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString(),  `
[System.Text.RegularExpressions.Regex]::Escape("$env:ChocolateyInstall\bin") + '(?>;)?', '', `
[System.Text.RegularExpressions.RegexOptions]::IgnoreCase) | `
%{[System.Environment]::SetEnvironmentVariable('PATH', $_, 'Machine')}

if ($env:ChocolateyBinRoot -ne '' -and $env:ChocolateyBinRoot -ne $null) { Remove-Item -Recurse -Force "$env:ChocolateyBinRoot" }
if ($env:ChocolateyToolsRoot -ne '' -and $env:ChocolateyToolsRoot -ne $null) { Remove-Item -Recurse -Force "$env:ChocolateyToolsRoot" }
[System.Environment]::SetEnvironmentVariable("ChocolateyBinRoot", $null, 'User')
[System.Environment]::SetEnvironmentVariable("ChocolateyToolsLocation", $null, 'User')
# Stray key that also needs removed to clean Chocolatey
reg.exe delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "ChocolateyInstall" /f

# Run Cleanmgr again.
Write-Host "Running CleanMgr with Sagerun:$CleanMgrSageSet"
Start-Process -Wait "cleanmgr" -ArgumentList "/sagerun:$CleanMgrSageSet"

# Clean up files (including those not addressed by cleanmgr)
# This list is a bit different from that in the dism cleanup script.
Write-Host "Clearing Files"
@(
    "$ENV:LOCALAPPDATA\Nuget",
    "$ENV:LOCALAPPDATA\temp\*",
    "$ENV:WINDIR\logs",
    "$ENV:WINDIR\temp\*",
    "$ENV:USERPROFILE\AppData\Local\Microsoft\Windows\WER\ReportArchive",
    "$ENV:USERPROFILE\AppData\Local\Microsoft\Windows\WER\ReportQueue",
    "$ENV:ALLUSERSPROFILE\Microsoft\Windows\WER\ReportArchive",
    "$ENV:ALLUSERSPROFILE\Microsoft\Windows\WER\ReportQueue",
    "$ENV:WINDIR\winsxs\manifestcache",
    "C:\ProgramData\PuppetLabs"
) | % {
      try {
        if(Test-Path $_) {
            Write-Host "Removing $_"
            Takeown /d Y /R /f $_
            Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
            Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
          }
        }
        catch {
            Write-Host "Ignoring Error - Continue"
        }

    }

# Clearing Logs
Write-Host "Clearing Logs"
wevtutil clear-log Application
wevtutil clear-log Security
wevtutil clear-log Setup
wevtutil clear-log System

# Display Free Space Statistics at end
$SpaceAtEnd = [Math]::Round( ((Get-WmiObject win32_logicaldisk | where { $_.DeviceID -eq $env:SystemDrive }).FreeSpace)/1GB, 2)
$SpaceReclaimed = $SpaceAtEnd - $SpaceAtStart

Write-Host "Cleaning Complete"
Write-Host "Starting Free Space $SpaceAtStart GB"
Write-Host "Current Free Space $SpaceAtEnd GB"
Write-Host "Reclaimed $SpaceReclaimed GB"

# TODO run sdelete a final time - only a suggestion as it may be useful to pare out the
# extra space released by the delete commands above.

# Extend C: partition to full extend - this is predicated on the existance of PS call.
# So Powershell Version 2 and earlier must resort to diskpart.
# Need to add extra check for Win-2008r2 even with WMF 5 added as this still breaks.

$WindowsVersion = (Get-WmiObject win32_operatingsystem).version
if ($psversiontable.psversion.major -gt 2 -and $WindowsVersion -ne '6.1.7601') {
  $size = (Get-PartitionSupportedSize -DriveLetter C)
  $sizemax = $size.SizeMax
  Write-Host "Setting Drive C partition size to $sizemax"
  Resize-Partition -DriveLetter C -Size $sizemax
}
else {
  Write-Host "Using DiskPart to extend C: drive partition"
  $diskpartcommands=@"
list disk
select disk 0
list partition
select partition 3
extend
list partition
exit
"@

  $diskpartcommands | diskpart
}

# Remove the pagefile
Write-Host "Removing page file.  Recreates on next boot"
reg.exe ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"    /v "PagingFiles" /t REG_MULTI_SZ /f /d """"

# Sleep to let console log catch up (and get captured by packer)
Start-Sleep -Seconds 20
#End
