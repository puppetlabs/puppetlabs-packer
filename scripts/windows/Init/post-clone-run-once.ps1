# This script is run immediately post-clone to configure the machine as a clone of the template.
#
$ErrorActionPreference = "Stop"

#--- Log Session ---#
Start-Transcript -Path "C:\Packer\Logs\post-clone-run-once.log"

#--- FUNCTIONS ---#
function ExitScript([int]$ExitCode){
	Stop-Transcript
	exit $ExitCode
}

function Rename-Host([string]$NewComputerName){
	$ComputerInfo = Get-WmiObject -Class Win32_ComputerSystem
	$ComputerInfo.Rename($NewComputerName) | Out-Null
}

function Restart-Host(){
	$OS = Get-WmiObject Win32_OperatingSystem
	$OS.PSBase.Scope.Options.EnablePrivileges = $true
	$OS.Win32Shutdown(6) | Out-Null
}

# Get VMPooler Guest name
# This is a bit roundabout, but it allows us to detect of the guestinfo.hostname is available or not
# Command is: vmtoolsd.exe --cmd "info-get guestinfo.hostname"'
#
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "$($env:ProgramFiles)\VMware\VMware Tools\vmtoolsd.exe"
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.Arguments = "--cmd ""info-get guestinfo.hostname"""
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
$p.WaitForExit()
$NewVMName = $p.StandardOutput.ReadToEnd()

# Exit with error code if name not found - likely to be the template machine.
if ($p.ExitCode -ne 0){
	Write-Warning "Could not find VM name in vSphere!`n"
	Write-Warning "If this machine is the template VM, no rename necessary!!"
	Write-Warning "Remember to reset the 'RunOnce' registry key by running C:\Packer\Init\vmpooler-arm-host.ps1"
	ExitScript 1
}

Write-Host "vSphere VMname: $NewVMName`n"

#Re-enable NetBIOS services
Set-Service "lmhosts" -StartupType Automatic
Set-Service "netbt" -StartupType Automatic

# Set Startup script (starts sshd)
Write-Host "Setting startup script"
reg import C:\Packer\Init\vmpooler-clone-arm-startup.reg

#Rename this machine to that of the VM name in vSphere
Rename-Host($NewVMName)

# NIC Power Management - ignore any errors as need host-rename to proceed.
Write-Host "Disabling NIC Power Management"
try {
	C:\Packer\Init\DisableNetworkAdapterPnPCapabilities.ps1
} catch {
	Write-Warning "Disable Power Management failed"
}


#Force restart machine.
Restart-Host

ExitScript 0
