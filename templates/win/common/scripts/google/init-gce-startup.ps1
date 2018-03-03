 
$PackerScriptsDir = $Env:PACKER_SCRIPTS_DIR

.  $PackerScriptsDir/windows-env.ps1

# THis script handles a numer of workarounds mostly for PS2 downgrades, including setting up a specialised scheduled task
# to fix the powershell settings and downloads related to github security issues that cobble PS2.
#

# Install Autologon now as once we downgrade Powershell and do other changes, the above code won't work....
#
# Pick it up directly from live.sysinternals.com and plant i
Download-File https://live.sysinternals.com/autologon.exe $SysInternals\autologon.exe

Write-Output "Updating path with $SysInternals"
$RegPath = 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
$OldPath = (Get-ItemProperty -Path $RegPath -Name PATH).Path
$NewPath = $OldPath + ';' + $SysInternals
Set-ItemProperty -Path $RegPath -Name PATH -Value $NewPath
Write-Output "Autologon Installed"

Write-Output "Collect Appveyor Password." 
$appveyor_json =  (Get-Content -raw -path c:\packer\init\appveyor.json | ConvertFrom-Json)
$appveyor_username = $appveyor_json.username
$appveyor_password = $appveyor_json.password

Write-Output "Appveyor Username: $appveyor_username"
$hostname = hostname

Write-Output "Create new GCE Startup Script"
schtasks /create /tn PackerAppveyorStartup /rl HIGHEST /ru "$appveyor_username" /RP "$appveyor_password" /F /SC ONSTART /DELAY 0000:20 /TR 'cmd /c c:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -ExecutionPolicy Bypass -NonInteractive -NoProfile -File C:\Packer\Scripts\gce-startup.ps1 >> c:\Packer\Logs\gce-startup.log'

$securePassword = ConvertTo-SecureString "$appveyor_password" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential "$appveyor_username", $securePassword
Write-Output "---------------------------"

# Create Profile for the appveyor account
Write-Output "---------------------------"
Write-Output "Creating $appveyor_username Profile" 
Start-Process Powershell -Wait -Credential $Credential -LoadUserProfile "Exit"
Write-Output "Appveyor profile created" 
Write-Output "---------------------------"

Write-Output "---------------------------"
Write-Output "Setting Autologon for $appveyor_username"
& $SysInternals\autologon "$appveyor_username" . "$appveyor_password" -AcceptEULA
Write-Output "appveyor Autologon set" 
Write-Output "---------------------------"
