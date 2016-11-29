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
Set-UserKey 'Software\Microsoft\Internet Explorer\Main' 'Start Page' 'REG_SZ' 'about:blank'

# UI and desktop settings (note classic is enforced by Group policy")
# Set Visual Effects for Best Performance
Write-Host "Setting Visual Effects to Best Performance"
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' 'VisualFXSetting' 'REG_DWORD' 2

# Set solid color background - blueish
Write-Host "Setting Solid background colour"
Set-UserKey 'Control Panel\Colors' 'Background' 'REG_SZ' '"10 59 118"'
Set-UserKey 'Control Panel\Colors' 'Wallpaper' 'REG_SZ' '""'

# Start Menu Options
Write-Host "Setting Start Menu Options"
# Control panel start-menu cascading doesn't appear to be available in W 2012
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel' 'AllItemsIconView' 'REG_DWORD' 1

# Icon Notification Tray - enable all notifications for the moment.
# Setting as per spec is tricky (see RE-7692)
Write-Host "Enabling all notification icons"
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer' 'EnableAutoTray' 'REG_DWORD' 0

# Set Explorer UI settings
Write-Host "Setting Explorer and Taskbar UI Settings..."
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'AlwaysShowMenus'       'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'AutoCheckSelect'       'REG_DWORD' 0
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'DisablePreviewDesktop' 'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'DontPrettyPath'        'REG_DWORD' 0
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Filter'                'REG_DWORD' 0
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Hidden'                'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideDrivesWithNoMedia' 'REG_DWORD' 0
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt'           'REG_DWORD' 0
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideIcons'             'REG_DWORD' 0
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideMergeConflicts'    'REG_DWORD' 0
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'IconsOnly'             'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ListviewAlphaSelect'   'REG_DWORD' 0
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ListviewShadow'        'REG_DWORD' 0
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ListviewWatermark'     'REG_DWORD' 0
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'MapNetDrvBtn'          'REG_DWORD' 0
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'SeparateProcess'       'REG_DWORD' 0
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ServerAdminUI'         'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCompColor'         'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowInfoTip'           'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowStatusBar'         'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowSuperHidden'       'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowTypeOverlay'       'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_SearchFiles'     'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'StartMenuAdminTools'   'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'StartMenuInit'         'REG_DWORD' 6
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'StoreAppsOnTaskbar'    'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarAnimations'     'REG_DWORD' 0
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarGlomLevel'      'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarSizeMove'       'REG_DWORD' 1
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarSmallIcons'     'REG_DWORD' 0
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'WebView'               'REG_DWORD' 1

# Set FullPath to be displayed in the window title bar
Write-Host "Setting Full Path to be displayed on title bars..."
Set-UserKey 'Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState' 'FullPath'          'REG_DWORD' 1

# Set some UI acceleration features to tune down all of the fancy animations etc..
Write-Host "Disabling fancy UI animations..."
Set-UserKey 'Control Panel\Desktop'               'DragFullWindows'           'REG_SZ'      '0'
Set-UserKey 'Control Panel\Desktop'               'FontSmoothing'             'REG_SZ'      '0'
Set-UserKey 'Control Panel\Desktop'               'UserPreferencesMask'       'REG_BINARY' '9000038010000000'
Set-UserKey 'Control Panel\Desktop\WindowMetrics' 'MinAnimate'                'REG_SZ'      '0'
Set-UserKey 'Software\Microsoft\Windows\DWM'      'AlwaysHibernateThumbnails' 'REG_DWORD'   0
Set-UserKey 'Software\Microsoft\Windows\DWM'      'EnableAeroPeek'            'REG_DWORD'   0

# Unload default user.
reg.exe unload HKLM\DEFUSER

# Set the Security Policies
Write-Host "Setting Low Security Password Policies"
secedit /configure /db secedit.sdb /cfg A:\Low-SecurityPasswordPolicy.inf /quiet

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

# Re-Enable AutoAdminLogon
autologon -AcceptEula Administrator . PackerAdmin

# End
