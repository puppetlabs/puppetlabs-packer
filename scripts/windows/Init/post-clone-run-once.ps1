# This script is run immediately post-clone to configure the machine as a clone of the template.
#
$ErrorActionPreference = "Stop"

Write-Host "Disabling NIC Power Management"
C:\Packer\Init\DisableNetworkAdapterPnPCapabilities.ps1

# Rename host using

# Final Sysprep generalise

Exit

# end

# #############################################################################
# Puppet Labs - POWERSHELL
#
# NAME: VsphereHostRename.ps1
# AUTHOR:  Ryan Gard
# DATE:  09/10/2013
# EMAIL: ryan.gard@puppetlabs.com
#
# #############################################################################

#--- Script Params ---#
#params ()

#--- Help ---#
<#
.SYNOPSIS
	Change the host name of the computer to that of the VMname on vSphere machines.
.DESCRIPTION
	Change the host name of the computer to that of the VMname on vSphere machines.
.PARAMETER
.INPUTS
.OUTPUTS
.EXAMPLE
#>

#--- Log Session ---#
Start-Transcript -Path "c:\vsphere_host_rename.log"

#--- Global ---#
$VsphereServer = "vmware-vc2.ops.puppetlabs.net"
$TemplateVMName = "win-2012r2-x86_64"

#--- MODULE/SNAPIN/DOT SOURCING/REQUIREMENTS ---#
if (-not(Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)){Add-PSSnapin VMware.VimAutomation.Core}

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

function Get-IPV4Address(){
	$ip = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled="TRUE" | Select-Object -First 1 -ExpandProperty "IPAddress" | Select-Object -First 1
	return $ip
}

function Get-MACAddress(){
	$mac = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled="TRUE" | Select-Object -First 1 -ExpandProperty "MACAddress"
	return $mac
}

function Get-VsphereVMname([string]$HostIP, [string]$HostMAC){
	$VMName = ""


	return $VMName
}

#--- SCRIPT ---#
Start-Sleep -s 30


#Gather machine info.
$HostIP = Get-IPV4Address
$HostMAC = Get-MACAddress

Write-Host "Host IP Address: $HostIP`n"
Write-Host "Host MAC Address: $HostMAC`n"

#Determine name of VM in vSphere
$NewVMName = Get-VsphereVMname $HostIP $HostMAC

#Freak out if name not found.
if ($NewVMName -eq ""){
	Write-Error "Could not find VM name in vSphere!`n"
	ExitScript 1
}
elseif ($NewVMName -eq $TemplateVMName){
	Write-Host "This machine is the template VM, no rename necessary!!"
	Write-Host "Remember to reset the 'RunOnce' registry key with this script!"

	sleep 5

	ExitScript 0
}

Write-Host "vSphere VMname: $NewVMName`n"

#Re-enable NetBIOS services
Set-Service "lmhosts" -StartupType Automatic
Set-Service "netbt" -StartupType Automatic

#Rename this machine to that of the VM name in vSphere
Rename-Host($NewVMName)

#Force restart machine.
Restart-Host

ExitScript 0
