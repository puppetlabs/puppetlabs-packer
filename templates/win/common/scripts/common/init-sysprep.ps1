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
  [switch]$Shutdown,
  [switch]$RemoveVMWare,
  [switch]$RunOncePrimed,
  [string]$ImageProvisioner = "vmware"
)

$ErrorActionPreference = 'Stop'

. C:\Packer\Scripts\windows-env.ps1

$rundate = date
Write-Output "Initialising sysrep for $ImageProvisioner at $rundate"

if ($RemoveVMWare -and (-not $RunOncePrimed)) {
    # Removing VMWare tools breaks the network and WinRM which causes the script to hang.
    # So setting a RunOnce Key here followed by a reboot to re-run the script immediately
    # on reboot. This appears to resolve the "hanging" issue and cleanly removes vmware tools.
    Write-Output "Setting up RunOnce to run VMWare Remove after Reboot"
    New-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" `
                     -Name "InitSysprep" `
                     -PropertyType String `
                     -Value "c:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -File C:\Packer\Scripts\init-sysprep.ps1 -RunOncePrimed -Shutdown -RemoveVMWare -ImageProvisioner platform9 >> C:\Packer\Logs\Init-Sysprep.log 2>&1"`
                     -Force `
                     -ErrorAction Continue
    Invoke-Reboot
    Exit 0
}

# Main script execution from this point.
Write-Output "Init-Sysrep Script continues here"

If ( ($WindowsVersion -like $WindowsServer2008R2) -and ($psversiontable.psversion.major -eq 5) ) {

    # WMF5/Win-2008r2 fails to sysprep without this fix.
    # Should really puppetize this - need to check if we have psversion fact
    
    Write-Output "Syspep fix for WMF5/Windows 2008R2"
    reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows\StreamProvider"    /v "LastFullPayloadTime" /t REG_DWORD /d 0 /f
}

# Run the Application Package Cleaner again if required.
if (Test-Path "$PackerLogs\AppsPackageRemove.Required") {
    # Stop the tilemode service
    Stop-Service -Name "tiledatamodelsvc" -Force -Verbose -ErrorAction SilentlyContinue
    Write-Output "Running Apps Package Cleaner post windows update"
    Remove-AppsPackages -AppPackageCheckpoint AppsPackageRemove.Pass2

    Write-Output "Listing state of all applications"
    Get-AppxPackage -AllUser | Format-List -Property Name,PackageFullName,PackageUserInformation,IsFramework
}

# Stop the tilemode service
Stop-Service -Name "tiledatamodelsvc" -Force -Verbose -ErrorAction SilentlyContinue
Stop-Service -Name "AppXSvc" -Force -Verbose -ErrorAction SilentlyContinue
Stop-Service -Name "staterepository" -Force -Verbose -ErrorAction SilentlyContinue

if ($RemoveVMWare) {
    # Disable VMWare tools - would prefer to uninstall but haven't been able to get the following command to work reliably.
    # Uninstall VMWare Tools using the GUID obtained from HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall
    Write-Output "Removing VMWare Tools"
    Start-Process "msiexec" -Wait -NoNewWindow -Verbose -ArgumentList "/x {F32C4E7B-2BF8-4788-8408-824C6896E1BB} /qn /norestart REBOOT=REALLYSUPPRESS"
    Write-Output "VMWare tools removed"
}

$SysPrepDir = "C:\Windows\System32\sysprep\"
$SysPrepArgs = "/generalize /oobe /quit /unattend:C:\Packer\Config\post-clone.autounattend.xml"
if ( ($ImageProvisioner -eq "vmware") -and ($WindowsVersion -notlike $WindowsServer2008R2) -and ($WindowsVersion -notlike $WindowsServer2008)) {
    # /mode:vm was only introduced from win-2012 onwards
    Write-Output "Using /mode:vm"
    $SysPrepArgs += " /mode:vm"
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
    Write-Output "Pre-Shutdown preparation - Disable Services"
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
