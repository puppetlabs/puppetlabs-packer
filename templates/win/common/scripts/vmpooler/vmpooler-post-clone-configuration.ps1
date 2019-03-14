# This script is run immediately post-clone to configure the machine as a clone of the template.
#

param (
    [string]$AdminUsername = "Administrator"
)

. C:\Packer\Scripts\windows-env.ps1

$rundate = date
write-output "Script: vmpooler-post-clone-configuration.ps1 Starting at: $rundate"

# Used Frequently throughout
$CygwinDir = "$ENV:CYGWINDIR"

# One off registry fix for background which isn't copied correctly from Default User profile
reg.exe ADD "HKCU\Control Panel\Colors" /v "Background" /t REG_SZ /d "10 59 118" /f

# First things first - resync time to make sure we aren't using ESX/VMware time (RE-8033)

If ($WindowsVersion -like $WindowsServer2008) {
  Write-Output "Resync Time not done for Win-2008"
}
else {
  Write-Output "Resyncing Time"
  net start w32time
  w32tm /resync
  w32tm /tz
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
$NewVMName = $p.StandardOutput.ReadToEnd().Trim()

# Give warning but continue to allow testing.
if ($p.ExitCode -ne 0){
  Write-Output "Could not find VM name in guestinfo"
  Write-Output "If this machine is the template VM, no rename necessary!!"
  $NewVMName = "testvm"
}

Write-Output "vSphere VMname: $NewVMName`n"

# Pickup Env Variables defined in "install-cygwin.ps1"
$CygWinShell = "$CygwinDir\bin\sh.exe"
$AdministratorHome = "$CygwinDir\home\$AdminUsername"

# Set up cygserv Username
Write-Output "Setting SSH Host Configuration"
$qa_root_passwd_plain = Get-Content "$ENV:CYGWINDOWNLOADS\qapasswd"
& $CygWinShell --login -c `'ssh-host-config --yes --privileged --user cyg_server --pwd $qa_root_passwd_plain`'

# Generate ssh keys.
Write-Output "Generate SSH Keys"
& $CygWinShell --login -c `'rm -rf /home/$AdminUsername/.ssh/id_rsa*`'
& $CygWinShell --login -c `'ssh-keygen -t rsa -N `"`" -f /home/$AdminUsername/.ssh/id_rsa`'

# Setup Authorised keys (now that home directory exists - with nasty cygpath conversion
Write-Output "Setup Authorised Keys"
& $CygWinShell --login -c `'cp /home/$AdminUsername/.ssh/id_rsa.pub /home/$AdminUsername/.ssh/authorized_keys`'
& $CygWinShell --login -c `'cat "/cygdrive/c/Packer/Config/authorized_keys.vmpooler" `>`> /home/$AdminUsername/.ssh/authorized_keys`'

# Setup LSA Authentication
Write-Output "Register the Cygwin LSA authentication package "
& $CygWinShell --login -c `'auto_answer="yes" /usr/bin/cyglsa-config`'

# Add github.com as a known host (needed for git@gihub:<repo> clone ops)
& $CygWinShell --login -c `'ssh-keyscan -t rsa github.com `>`> /home/$AdminUsername/.ssh/known_hosts`'


# Update machine password (and reset autologin)
Write-Output "Setting $AdminUsername Password"
net user $AdminUsername "$qa_root_passwd_plain"
autologon -AcceptEula $AdminUsername . "$qa_root_passwd_plain"

# Generate passwd and group files.
Write-Output "Generating Passwd Files"
$CygwinMkpasswd = "$CygwinDir\bin\mkpasswd.exe -l"
$CygwinMkgroup = "$CygwinDir\bin\mkgroup.exe -l"
$CygwinPasswdFile = "$CygwinDir\etc\passwd"
$CygwinGroupFile = "$CygwinDir\etc\group"
Invoke-Expression $CygwinMkpasswd | Out-File $CygwinPasswdFile -Force -Encoding "ASCII"
Invoke-Expression $CygwinMkgroup | Out-File $CygwinGroupFile -Force -Encoding "ASCII"

# NIC Power Management - ignore any errors as need host-rename to proceed.
Write-Output "Disabling NIC Power Management"
try {
  C:\Packer\Scripts\DisableNetworkAdapterPnPCapabilities.ps1
} catch {
  Write-Warning "Disable Power Management failed"
}

# Set Service startups following the reboot/rename operation.
Write-Output "Re-enable NETBios and WinRM Services"
Set-Service "lmhosts" -StartupType Automatic
Set-Service "netbt" -StartupType Automatic
Set-Service "WinRM" -StartupType Automatic
Write-Output "Set SSHD to start after next boot"
Set-Service "sshd" -StartupType Automatic

# Create BGINFO Scheduled Task to update the lifetime every 20 minutes
If ( -not $WindowsServerCore ) {
  schtasks /create /tn UpdateBGInfo /ru "$AdminUsername" /RP "$qa_root_passwd_plain" /F /SC Minute /mo 20 /IT /TR 'C:\Packer\Scripts\sched-bginfo.vbs'
}

# Queue startup script to run as scheduled task rather than as RunOnce (which stricly speaking isn't supported on Core)
Write-Output "Setting startup script"
schtasks /create /tn VMPoolerStartup /rl HIGHEST /ru "$AdminUsername" /RP "$qa_root_passwd_plain" /F /SC ONSTART /IT /TR 'cmd /c c:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -ExecutionPolicy Bypass -NonInteractive -NoProfile -File C:\Packer\Scripts\vmpooler-clone-startup.ps1 >> c:\Packer\Logs\vmpooler-clone-startup.log  2>&1'

# Pin apps to taskbar as long as we aren't win-10/2016
if ($WindowsVersion -notlike $WindowsServer2016) {
  try {
    Write-Output "Pin Apps to Taskbar"
    & $PackerScripts\Pin-AppsToTaskBar.ps1
  }
  catch {
    Write-Output "Ignoring Pin App errors"
  }
}
# Rename this machine to that of the VM name in vSphere
# Windows 7/2008R2- and earlier doesn't use the Rename-Computer cmdlet
Write-Output "Renaming Host to $NewVMName"
if ($WindowsVersion -like $WindowsServer2008R2 -or $WindowsVersion -like $WindowsServer2008) {
  $(gwmi win32_computersystem).Rename("$NewVMName")
  shutdown /t 0 /r /f
}
else {
  Rename-Computer -Newname $NewVMName -Restart
}
Exit 0
