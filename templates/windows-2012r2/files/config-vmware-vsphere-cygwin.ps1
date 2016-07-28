# Registry and other settings that are easier done outside puppet for the moment.
# These tend to be OS specific so will be left in the OS area.
#
$ErrorActionPreference = "Stop"

. A:\windows-env.ps1

# Some other quick win settings provided by Boxstarter
# Although this is no longer run under boxstarter, we are still able to use it's cmdlets.
Write-Host "Other Stuff......."

# Enable Bootlog
Write-Host "Enable Bootlog"
cmd /c "bcdedit /set {current} bootlog yes"

# Load Default User for registry to accomodate changes.
reg.exe load HKLM\DEFUSER c:\users\default\ntuser.dat

#Disable UAC for Windows-2012
Disable-UAC

# Enable Remote Desktop (with reduce authentication resetting here again)
Enable-RemoteDesktop -DoNotRequireUserLevelAuthentication

# Set IE Home Page for this and Default User.
reg.exe ADD "HKCU\Software\Microsoft\Internet Explorer\Main" /v "Start Page" /t REG_SZ /d "about:blank" /f
reg.exe ADD "HKLM\DEFUSER\Software\Microsoft\Internet Explorer\Main" /v "Start Page" /t REG_SZ /d "about:blank" /f

# Unload default user.
reg.exe unload HKLM\DEFUSER

# Configure WinRM - (Final configuration)
Write-Host "Configuring WinRM"
winrm quickconfig -force
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="512"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
