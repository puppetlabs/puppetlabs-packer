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

#Disable UAC for Windows-2012
Disable-UAC

# Enable Remote Desktop (with reduce authentication resetting here again)
Enable-RemoteDesktop -DoNotRequireUserLevelAuthentication

#######################################################################################################################
# Ideally these registry settings would be done through puppet.
# Unfortunately there is a puppet registry module restriction on manipulating HKCU, so need to use
# Powershell commands here instead.
# TODO Migrate these to the puppet settings once the HKCU restriction is removed.
#######################################################################################################################

# Load Default User for registry to accomodate changes.
# All HKCU changes are replicated for the default user.
reg.exe load HKLM\DEFUSER c:\users\default\ntuser.dat

# Set IE Home Page for this and Default User.
Write-Host "Setting IE Home Page"
reg.exe ADD "HKCU\Software\Microsoft\Internet Explorer\Main" /v "Start Page" /t REG_SZ /d "about:blank" /f
reg.exe ADD "HKLM\DEFUSER\Software\Microsoft\Internet Explorer\Main" /v "Start Page" /t REG_SZ /d "about:blank" /f

# UI and desktop settings (note classic is enforced by Group policy")
# Set Visual Effects for Best Performance
Write-Host "Setting Visual Effects to Best Performance"
reg.exe ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f
reg.exe ADD "HKLM\DEFUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f

# Set solid color background - blueish
Write-Host "Setting Solid background colour"
reg.exe ADD "HKCU\Control Panel\Colors" /v "Background" /t REG_SZ /d "10 59 118" /f
reg.exe ADD "HKLM\DEFUSER\Control Panel\Colors" /v "Background" /t REG_SZ /d "10 59 118" /f
reg.exe ADD "HKCU\Control Panel\Desktop" /v "Wallpaper" /t REG_SZ /d '""' /f
reg.exe ADD "HKLM\DEFUSER\Control Panel\Desktop" /v "Wallpaper" /t REG_SZ /d '""' /f

# Start Menu Options
Write-Host "Setting Start Menu Options"
# Control panel start-menu cascading doesn't appear to be available in W 2012
reg.exe ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v "AllItemsIconView" /t REG_DWORD /d 1 /f
reg.exe ADD "HKLM\DEFUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v "AllItemsIconView" /t REG_DWORD /d 1 /f

# Icon Notification Tray - enable all notifications for the moment.
# Setting as per spec is tricky (see RE-7692)
Write-Host "Enabling all notification icons"
reg.exe ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "EnableAutoTray" /t REG_DWORD /d 0 /f
reg.exe ADD "HKLM\DEFUSER\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "EnableAutoTray" /t REG_DWORD /d 0 /f

# Unload default user.
reg.exe unload HKLM\DEFUSER

# Configure WinRM - (Final configuration)
Write-Host "Configuring WinRM"
winrm quickconfig -force
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

# Add permissive Firewall rules (RE-7516) - This is preferred to disabling the firewall
netsh advfirewall firewall add rule name="All Incoming" dir=in action=allow enable=yes interfacetype=any profile=any localip=any remoteip=any
netsh advfirewall firewall add rule name="All Outgoing" dir=out action=allow enable=yes interfacetype=any profile=any localip=any remoteip=any

# Cygwin configuration (Cygwin packages only)
