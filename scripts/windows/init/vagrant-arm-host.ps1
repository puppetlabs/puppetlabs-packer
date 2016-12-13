# vagrant host Arming - this is is done during the maching prep as a post-clone operation is
# not required for current vagrant testing.

$ErrorActionPreference = 'Stop'

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
& $CygWinShell --login -c `'cat "/cygdrive/c/Packer/Init/authorized_keys.vagrant" `>`> /home/Administrator/.ssh/authorized_keys`'

Write-Host "Create vagrant directory and setup ssh for it"
& $CygWinShell --login -c `'mkdir /home/vagrant`'
& $CygWinShell --login -c `'cp -r /home/Administrator/.ssh /home/vagrant`'
& $CygWinShell --login -c `'chown -R vagrant /home/vagrant`'

Write-Host "Add SSHD Process with Manual Startup"
& $CygWinShell --login -c `'cygrunsrv -S sshd`'
Set-Service "sshd" -StartupType Manual

# Set Startup script (starts sshd)
Write-Host "Setting startup script"
reg import C:\Packer\Init\vmpooler-clone-arm-startup.reg


# End
