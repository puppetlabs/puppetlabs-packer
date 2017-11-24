# vagrant host Arming - this is is done during the maching prep as a post-clone operation is
# not required for current vagrant testing.

$ErrorActionPreference = 'Stop'

# Pickup Env Variables defined in "install-cygwin.ps1"
$CygWinShell = "$ENV:CYGWINDIR\bin\sh.exe"
$CygwinDownloads = $ENV:CYGWINDOWNLOADS
$AdministratorName =  (Get-WmiObject win32_useraccount -Filter "Sid like 'S-1-5-21-%-500'").Name
$AdministratorHome = "$ENV:CYGWINDIR\home\$AdministratorName"

# Set up cygserv Username
Write-Output "Setting SSH Host Configuration"
& $CygWinShell --login -c `'ssh-host-config --yes --privileged --user cyg_server --pwd vagrant`'

# Generate ssh keys.
Write-Output "Generate SSH Keys"
& $CygWinShell --login -c `'rm -rf /home/vagrant/.ssh/id_rsa*`'
& $CygWinShell --login -c `'ssh-keygen -t rsa -N `"`" -f /home/vagrant/.ssh/id_rsa`'

# Setup Authorised keys (now that home directory exists - with nasty cygpath conversion
Write-Output "Setup Authorised Keys"
& $CygWinShell --login -c `'cp /home/vagrant/.ssh/id_rsa.pub /home/vagrant/.ssh/authorized_keys`'
& $CygWinShell --login -c `'cat "/cygdrive/c/Packer/Init/authorized_keys.vagrant" `>`> /home/vagrant/.ssh/authorized_keys`'

# Setup LSA Authentication
Write-Output "Register the Cygwin LSA authentication package "
& $CygWinShell --login -c `'auto_answer="yes" /usr/bin/cyglsa-config`'

# Add github.com as a known host (needed for git@gihub:<repo> clone ops)
& $CygWinShell --login -c `'ssh-keyscan -t rsa github.com `>`> /home/vagrant/.ssh/known_hosts`'

Write-Output "Add SSHD Process with Manual Startup"
& $CygWinShell --login -c `'cygrunsrv -S sshd`'
Set-Service "sshd" -StartupType Manual

# Make sure the C:/Users/$AdministratorName directory is created by running a dummy-command to create the profile.
Write-Output "Setting $AdministratorName Account Password"
$qa_root_passwd = Get-Content "$ENV:CYGWINDOWNLOADS\qapasswd"
net user $AdministratorName "$qa_root_passwd"
$password = "$qa_root_passwd"
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $AdministratorName, $securePassword
Write-Output "Creating $AdministratorName Profile"
Start-Process Powershell -Wait -Credential $Credential -LoadUserProfile "Exit"

# Create $AdministratorName cygwin as well
Write-Output "Creating $AdministratorName ssh/cygwin home directory"
& $CygWinShell --login -c `'mkdir -p /home/$AdministratorName`'
& $CygWinShell --login -c `'chown $AdministratorName /home/$AdministratorName`'

# Set Startup script (starts sshd)
Write-Output "Setting startup script"
reg import C:\Packer\Init\vagrant-clone-arm-startup.reg

Write-Output "Setting vagrant to autologon"
autologon -AcceptEula vagrant . vagrant

#End
