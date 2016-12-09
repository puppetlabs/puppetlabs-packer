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

# One off registry fix for background which isn't copied correctly from Default User profile
reg.exe ADD "HKCU\Control Panel\Colors" /v "Background" /t REG_SZ /d "10 59 118" /f

# First things first - resync time to make sure we aren't using ESX/VMware time (RE-8033)
Write-Host "Resyncing Time"
w32tm /resync
w32tm /tz

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
$NewVMName = $p.StandardOutput.ReadToEnd().Trim()

# Exit with error code if name not found - likely to be the template machine.
if ($p.ExitCode -ne 0){
	Write-Warning "Could not find VM name in vSphere!`n"
	Write-Warning "If this machine is the template VM, no rename necessary!!"
	Write-Warning "Remember to reset the 'RunOnce' registry key by running C:\Packer\Init\vmpooler-arm-host.ps1"
	ExitScript 1
}

Write-Host "vSphere VMname: $NewVMName`n"

# Pickup Env Variables defined in "install-cygwin.ps1"
$CygWinShell = "$ENV:CYGWINDIR\bin\sh.exe"
$CygwinDownloads = $ENV:CYGWINDOWNLOADS
$AdministratorHome = "$ENV:CYGWINDIR\home\Administrator"

# Set up cygserv Username
Write-Host "Setting SSH Host Configuration"
$qa_root_passwd = Get-Content "$ENV:CYGWINDOWNLOADS\qapasswd"
& $CygWinShell --login -c `'ssh-host-config --yes --privileged --user cyg_server --pwd $qa_root_passwd`'

# Generate ssh keys.
Write-Host "Generate SSH Keys"
& $CygWinShell --login -c `'rm -rf /home/Administrator/.ssh/id_rsa*`'
& $CygWinShell --login -c `'ssh-keygen -t rsa -N `"`" -f /home/Administrator/.ssh/id_rsa`'

# Setup Authorised keys (now that home directory exists - with nasty cygpath conversion
Write-Host "Setup Authorised Keys"
& $CygWinShell --login -c `'cp /home/Administrator/.ssh/id_rsa.pub /home/Administrator/.ssh/authorized_keys`'
& $CygWinShell --login -c `'cat "/cygdrive/c/Packer/Init/authorized_keys.vmpooler" `>`> /home/Administrator/.ssh/authorized_keys`'

Write-Host "Add SSHD Process with Manual Startup"
& $CygWinShell --login -c `'cygrunsrv -S sshd`'
Set-Service "sshd" -StartupType Manual

Write-Host "Re-enable NETBios Services"
Set-Service "lmhosts" -StartupType Automatic
Set-Service "netbt" -StartupType Automatic

# Set Startup script (starts sshd)
Write-Host "Setting startup script"
reg import C:\Packer\Init\vmpooler-clone-arm-startup.reg

# Update machine password (and reset autologin)
Write-Host "Setting Administrator Password"
net user Administrator "$qa_root_passwd"
autologon -AcceptEula Administrator . "$qa_root_passwd"

# NIC Power Management - ignore any errors as need host-rename to proceed.
Write-Host "Disabling NIC Power Management"
try {
	C:\Packer\Init\DisableNetworkAdapterPnPCapabilities.ps1
} catch {
	Write-Warning "Disable Power Management failed"
}


# Rename this machine to that of the VM name in vSphere
# Windows 7/2008R2- and earlier doesn't use the Rename-Computer cmdlet
Write-Host "Renaming Host to $NewVMName"
$WindowsVersion = (Get-WmiObject win32_operatingsystem).version
if ($WindowsVersion -eq '6.1.7601' -or $WindowsVersion -eq '6.0.6002') {
	$(gwmi win32_computersystem).Rename("$NewVMName")
	shutdown /t 0 /r /f
}
else {
	Rename-Computer -Newname $NewVMName -Restart
}
ExitScript 0
