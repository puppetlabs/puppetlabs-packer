
#--- Log Session ---#
Start-Transcript -Path "C:\Packer\Logs\vmpooler-clone-startup.log"

# CYGWINDIR is set in the environment when Cygwin is installed
$CygwinDir = "$ENV:CYGWINDIR"
$CygwinMkpasswd = "$CygwinDir\bin\mkpasswd.exe -l"
$CygwinMkgroup = "$CygwinDir\bin\mkgroup.exe -l"
$CygwinPasswdFile = "$CygwinDir\etc\passwd"
$CygwinGroupFile = "$CygwinDir\etc\group"

#--- FUNCTIONS ---#
function ExitScript([int]$ExitCode){
	Stop-Transcript
	exit $ExitCode
}

#--- SCRIPT ---#
Write-Output "Updating the Cygwin passwd file!"

#Snooze for a bit
sleep -s 10

#Update the passwd file.
Invoke-Expression $CygwinMkpasswd | Out-File $CygwinPasswdFile -Force -Encoding "ASCII"
Invoke-Expression $CygwinMkgroup | Out-File $CygwinGroupFile -Force -Encoding "ASCII"

#Start the SSH server
Write-Output "Starting SSH server!"
Start-Service "sshd"

#Make sure WinRM is running
Set-Service "WinRM" -StartupType Automatic -Status Running

ExitScript 0
