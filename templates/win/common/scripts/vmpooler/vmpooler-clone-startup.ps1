# #############################################################################
# Puppet Labs - POWERSHELL
#
# NAME: vmpooler-clone-startup.ps1
# AUTHOR:  Ryan Gard, John O'Connor
# DATE:  29/07/2016 (proper dates apply :))
# EMAIL: john.oconnor@puppet.com
#
# #############################################################################

#--- Script Params ---#
#params ()

#--- Help ---#
<#
.SYNOPSIS
	Update the passwd shadow file and start the SSH server.
.DESCRIPTION
	Update the passwd shadow file and start the SSH server.
.PARAMETER
.INPUTS
.OUTPUTS
.EXAMPLE
#>

#--- Log Session ---#
Start-Transcript -Path "C:\Packer\Logs\vmpooler-clone-startup.log"

# CYGWINDIR is set in the environment when Cygwin is installed
$CygwinDir = "$ENV:CYGWINDIR"
$CygwinMkpasswd = "$CygwinDir\bin\mkpasswd.exe -l"
$CygwinMkgroup = "$CygwinDir\bin\mkgroup.exe -l"
$CygwinPasswdFile = "$CygwinDir\etc\passwd"
$CygwinGroupFile = "$CygwinDir\etc\group"

#Snooze for a bit
sleep -s 10

#--- SCRIPT ---#
Write-Output "Updating the Cygwin passwd file!"

#Update the passwd file.
Invoke-Expression $CygwinMkpasswd | Out-File $CygwinPasswdFile -Force -Encoding "ASCII"
Invoke-Expression $CygwinMkgroup | Out-File $CygwinGroupFile -Force -Encoding "ASCII"
