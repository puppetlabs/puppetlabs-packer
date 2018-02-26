 
$PackerScriptsDir = $Env:PACKER_SCRIPTS_DIR

.  $PackerScriptsDir/windows-env.ps1

# THis script handles a numer of workarounds mostly for PS2 downgrades, including setting up a specialised scheduled task
# to fix the powershell settings and downloads related to github security issues that cobble PS2.
#

Write-Output "Collect Appveyor Password." 
$appveyor_json = get-content -path c:\packer\init\appveyor.json
[System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions") | Out-Null
$ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
$appveyor_data = $ser.DeserializeObject($appveyor_json)
$appveyor_username = ($appveyor_data).username
$appveyor_password = ($appveyor_data).password

Write-Output "Appveyor Username: $appveyor_username"
$hostname = hostname

Write-Output "Create new GCE Startup Script"
schtasks /create /tn PackerAppveyorStartup /rl HIGHEST /ru "$appveyor_username" /RP "$appveyor_password" /F /SC ONSTART /DELAY 0000:20 /TR 'cmd /c c:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -sta -WindowStyle Hidden -ExecutionPolicy Bypass -NonInteractive -NoProfile -File C:\Packer\Scripts\gce-startup.ps1 >> c:\Packer\Logs\gce-startup.log'
