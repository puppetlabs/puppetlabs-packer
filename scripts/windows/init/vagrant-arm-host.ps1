# vagrant host Arming - this is is done during the maching prep as a post-clone operation is
# not required for current vagrant testing.

$ErrorActionPreference = 'Stop'

# Pickup Env Variables defined in "install-cygwin.ps1"
$CygWinShell = "$ENV:CYGWINDIR\bin\sh.exe"
$CygwinDownloads = $ENV:CYGWINDOWNLOADS
$AdministratorHome = "$ENV:CYGWINDIR\home\Administrator"

# Set up cygserv Username
Write-Host "Setting SSH Host Configuration"
& $CygWinShell --login -c `'ssh-host-config --yes --privileged --user cyg_server --pwd vagrant`'

# Generate ssh keys.
Write-Host "Generate SSH Keys"
& $CygWinShell --login -c `'rm -rf /home/vagrant/.ssh/id_rsa*`'
& $CygWinShell --login -c `'ssh-keygen -t rsa -N `"`" -f /home/vagrant/.ssh/id_rsa`'

# Setup Authorised keys (now that home directory exists - with nasty cygpath conversion
Write-Host "Setup Authorised Keys"
& $CygWinShell --login -c `'cp /home/vagrant/.ssh/id_rsa.pub /home/vagrant/.ssh/authorized_keys`'
& $CygWinShell --login -c `'cat "/cygdrive/c/Packer/Init/authorized_keys.vagrant" `>`> /home/vagrant/.ssh/authorized_keys`'

# Add github.com as a known host (needed for git@gihub:<repo> clone ops)
& $CygWinShell --login -c `'ssh-keyscan -t rsa github.com `>`> /home/vagrant/.ssh/known_hosts`'

Write-Host "Add SSHD Process with Manual Startup"
& $CygWinShell --login -c `'cygrunsrv -S sshd`'
Set-Service "sshd" -StartupType Manual

# Make sure the C:/Users/Administrator directory is created by running a dummy-command to create the profile.
Write-Host "Setting Administrator Account Password"
$qa_root_passwd = Get-Content "$ENV:CYGWINDOWNLOADS\qapasswd"
net user Administrator "$qa_root_passwd"
$username = "Administrator"
$password = "$qa_root_passwd"
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $username, $securePassword
Write-Host "Creating Administrator Profile"
Start-Process Powershell -Wait -Credential $Credential -LoadUserProfile "Exit"

# Create Administrator cygwin as well
Write-Host "Creating Administrator ssh/cygwin home directory"
& $CygWinShell --login -c `'mkdir -p /home/Administrator`'
& $CygWinShell --login -c `'chown Administrator /home/Administrator`'

# Set Startup script (starts sshd)
Write-Host "Setting startup script"
reg import C:\Packer\Init\vagrant-clone-arm-startup.reg

Write-Host "Setting vagrant to autologon"
autologon -AcceptEula vagrant . vagrant

#End
