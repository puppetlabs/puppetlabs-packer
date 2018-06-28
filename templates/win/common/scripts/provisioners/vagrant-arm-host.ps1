# vagrant host Arming - this is is done during the maching prep as a post-clone operation is
# not required for current vagrant testing.

$ErrorActionPreference = 'Stop'

# If we are Windows-10/2016 need to set network adapters private.
# Note - need longhand test as windows_env isn't available here.
if ($WindowsVersion -like "10.*") {
  # Setting Windows-10 network connections private.
  Set-NetConnectionProfile  -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex -NetworkCategory Private
}

# Pickup Env Variables defined in "install-cygwin.ps1"
$CygWinShell = "$ENV:CYGWINDIR\bin\sh.exe"
$CygwinDownloads = $ENV:CYGWINDOWNLOADS
$AdministratorName =  (Get-WmiObject win32_useraccount -Filter "Sid like 'S-1-5-21-%-500'").Name
$AdministratorHome = "$ENV:CYGWINDIR\home\$AdministratorName"
Write-Output "Administrator Name set as: $AdministratorName Home Directory is: $AdministratorHome"

# Crude Code to make sure we have Administrator Account enabled as well with localisation
$PrimaryLanguage = (Get-Culture).TwoLetterISOLanguageName
Switch ($PrimaryLanguage) {
  "fr"  {$AdminMasterName = "Administrateur"; break}
  default {$AdminMasterName = "Administrator"; break}
}

# Make sure Adminstrator (whatever it is called is active)
net user "$AdministratorName" /active:yes
net user "$AdminMasterName" /active:yes

# Create vagrant account
Write-Output "Creating Vagrant Account"
net user vagrant vagrant /ADD
net user vagrant /active:yes
wmic useraccount where 'name = "vagrant"' set PasswordExpires=FALSE

# Add vagrant to Administrators (localised) group
$HostName=hostname
$objSID = New-Object System.Security.Principal.SecurityIdentifier ("S-1-5-32-544")
$AdminsString = (($objSID.Translate( [System.Security.Principal.NTAccount])).value).split("\")[1]
[ADSI]$Admins="WinNT://$HostName/$AdminsString,group"
$Admins.psbase.Invoke("Add",([ADSI]"WinNT://$HostName/vagrant").path)

# Create a login profile for the vagrant account
$securePassword = ConvertTo-SecureString "vagrant" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential "vagrant", $securePassword
Write-Output "Creating vagrant Profile"
Start-Process Powershell -Wait -Credential $Credential -LoadUserProfile "Exit"

# Creating Home directories for vagrant
Write-Output "Create vagrant directories now"
& $CygWinShell --login -c `'mkdir /home/vagrant`'
& $CygWinShell --login -c `'mkdir /home/vagrant/.ssh`'

#Rework password files.
$CygwinDir = "$ENV:CYGWINDIR"
$CygwinMkpasswd = "$CygwinDir\bin\mkpasswd.exe -l"
$CygwinMkgroup = "$CygwinDir\bin\mkgroup.exe -l"
$CygwinPasswdFile = "$CygwinDir\etc\passwd"
$CygwinGroupFile = "$CygwinDir\etc\group"

#Update the passwd file.
Invoke-Expression $CygwinMkpasswd | Out-File $CygwinPasswdFile -Force -Encoding "ASCII"
Invoke-Expression $CygwinMkgroup | Out-File $CygwinGroupFile -Force -Encoding "ASCII"

# Set up cygserv Username
Write-Output "Setting SSH Host Configuration"
$qa_root_passwd_plain = Get-Content "$ENV:CYGWINDOWNLOADS\qapasswd"
& $CygWinShell --login -c `'ssh-host-config --yes --privileged --user cyg_server --pwd $qa_root_passwd_plain`'

# Generate ssh keys for both Administrator and vagrant
Write-Output "Generate SSH Keys"
& $CygWinShell --login -c `'rm -rf /home/$AdministratorName/.ssh/id_rsa*`'
& $CygWinShell --login -c `'ssh-keygen -t rsa -N `"`" -f /home/$AdministratorName/.ssh/id_rsa`'
& $CygWinShell --login -c `'cp /home/$AdministratorName/.ssh/id_rsa /home/vagrant/.ssh/id_rsa`'

# Setup Authorised keys (now that home directory exists - with nasty cygpath conversion
Write-Output "Setup Authorised Keys"
& $CygWinShell --login -c `'cp /home/$AdministratorName/.ssh/id_rsa.pub /home/$AdministratorName/.ssh/authorized_keys`'
& $CygWinShell --login -c `'cp /home/$AdministratorName/.ssh/id_rsa.pub /home/vagrant/.ssh/authorized_keys`'
& $CygWinShell --login -c `'cat "/cygdrive/c/Packer/Config/authorized_keys.vagrant" `>`> /home/$AdministratorName/.ssh/authorized_keys`'
& $CygWinShell --login -c `'cat "/cygdrive/c/Packer/Config/authorized_keys.vagrant" `>`> /home/vagrant/.ssh/authorized_keys`'

# Setup LSA Authentication
Write-Output "Register the Cygwin LSA authentication package "
& $CygWinShell --login -c `'auto_answer="yes" /usr/bin/cyglsa-config`'

# Add github.com as a known host (needed for git@gihub:<repo> clone ops)
& $CygWinShell --login -c `'ssh-keyscan -t rsa github.com `>`> /home/$AdministratorName/.ssh/known_hosts`'
& $CygWinShell --login -c `'ssh-keyscan -t rsa github.com `>`> /home/vagrant/.ssh/known_hosts`'

# Fixup permissions
& $CygWinShell --login -c `'chmod og-rwx /home/vagrant/.ssh`'
& $CygWinShell --login -c `'chown -R vagrant /home/vagrant`'

Write-Output "Add SSHD Process with Manual Startup"
& $CygWinShell --login -c `'cygrunsrv -S sshd`'
Set-Service "sshd" -StartupType Manual

#Update the passwd file (Again).
Invoke-Expression $CygwinMkpasswd | Out-File $CygwinPasswdFile -Force -Encoding "ASCII"
Invoke-Expression $CygwinMkgroup | Out-File $CygwinGroupFile -Force -Encoding "ASCII"

#Snooze for a bit
sleep -s 10

#Ensure sshd and WinRM services start after next book
Write-Output "Starting SSH server!"
Set-Service "sshd" -StartupType Automatic
Set-Service "WinRM" -StartupType Automatic

Write-Output "Setting vagrant to autologon"
autologon -AcceptEula vagrant . vagrant

#End
