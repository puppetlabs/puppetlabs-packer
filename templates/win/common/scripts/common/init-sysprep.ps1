# On Platform Sysprep Script
# This initiates the sysprep after doing some essential preparations, the main one being to do a final sweep
# to deprovision as many apps as possible and stop the tiledatamodelsvc
# This script then exits and it it she responsibility of packer to either shut the machine down (for vmpooler), or
# reboot it (to continue vagrant arming)
# Note the start/wait options are used to ensure that sysprep has completed.
# May add some further tests in here to try catch any errors in the panther logs as these could be very useful on
# an ongoing basis.


param(
  [switch]$Restart,
  [switch]$Shutdown
)

$ErrorActionPreference = 'Stop'

. C:\Packer\Scripts\windows-env.ps1

If ( ($WindowsVersion -like $WindowsServer2008R2) -and ($psversiontable.psversion.major -eq 5) ) {

    # WMF5/Win-2008r2 fails to sysprep without this fix.
    # Should really puppetize this - need to check if we have psversion fact
    
    Write-Output "Syspep fix for WMF5/Windows 2008R2"
    reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\StreamProvider"    /v "LastFullPayloadTime" /t REG_DWORD /d 0 /f
}

# Run the Application Package Cleaner again if required.
if (Test-Path "$PackerLogs\AppsPackageRemove.Required") {
    # Stop the tilemode service
    net stop tiledatamodelsvc
    Write-Output "Running Apps Package Cleaner post windows update"
    Remove-AppsPackages -AppPackageCheckpoint AppsPackageRemove.Pass2

    Write-Output "Listing state of all applications"
    Get-AppxPackage -AllUser | Format-List -Property Name,PackageFullName,PackageUserInformation,IsFramework

}

# Stop the tilemode service
Stop-Service -Name "tiledatamodelsvc" -Force -Verbose -ErrorAction SilentlyContinue
Stop-Service -Name "AppXSvc" -Force -Verbose -ErrorAction SilentlyContinue
Stop-Service -Name "staterepository" -Force -Verbose -ErrorAction SilentlyContinue

$SysPrepDir = "C:\Windows\System32\sysprep\"
$SysPrepArgs = "/generalize /oobe /quit /mode:vm /unattend:C:\Packer\Config\post-clone.autounattend.xml"
if ( ($WindowsVersion -like $WindowsServer2008R2) -or ($WindowsVersion -like $WindowsServer2008) ) {
    # /mode:vm was only introduced from win-2012 onwards
    $SysPrepArgs = "/generalize /oobe /quit /unattend:C:\Packer\Config\post-clone.autounattend.xml"
}
Write-Output "Starting the Sysprep Process"
$zproc = Start-Process "$SysPrepDir\sysprep.exe" @SprocParms -ArgumentList "$SysPrepArgs"
$zproc.WaitForExit()
$zProcExit = $zproc.ExitCode
Write-Output "Sysprep has completed with exit code $zProcExit"

Start-Sleep -Seconds 10
# Output the Sysprep Error Log
#
Write-Output "Sysprep Error Log"
Get-Content "$SysPrepDir\Panther\setuperr.log" | foreach {Write-Output $_}
Write-Output "-----------------"

# Test if Sysprep Succeeded - otherwise exit with an error code (1)

if (-not (Test-Path "$SysPrepDir\Sysprep_succeeded.tag")) {
    Write-Output "SysPrep Failed - Exit with error"
    Exit 1
}
Elseif ($Restart) {
    Write-Output "Restart to complete Sysprep"
    Restart-Computer -Force
}
Elseif ($Shutdown) {
    Write-Host "Pre-Shutdown preparation - Disable Services"
    # Make sure NetBios is disabled on the host to avoid netbios name collision at first boot.
    # Also disable VMWare USB Arbitration service (ignore errors if it is not there)
    Set-Service "lmhosts" -StartupType Disabled
    Set-Service "netbt" -StartupType Disabled
    Set-Service "VMUSBArbService" -StartupType Disabled  -ErrorAction SilentlyContinue

    Write-Output "Shutting down - next boot will complete sysprep"
    Shutdown-PackerBuild
}
Write-Output "Fall-Thru - exit cleanly"
Exit 0
