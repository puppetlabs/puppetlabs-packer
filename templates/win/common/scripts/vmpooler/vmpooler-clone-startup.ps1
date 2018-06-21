# VMPooler Startup Script
# This is now run as a scheduled task at boot.

. C:\Packer\Scripts\windows-env.ps1

$ErrorActionPreference = "Stop"

# Run vmstoolsd
Write-Output "Starting vmstoolsd"
$VMToolsd = "$($env:ProgramFiles)\VMware\VMware Tools\vmtoolsd.exe"
& $VMToolsd -n vmusr

# Run the BGInfo Task at startup, as scheduler will wait 5 mins.
If ( -not $WindowsServerCore ) {
    schtasks /run /tn UpdateBGInfo
}

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

Write-Output "Bye"
