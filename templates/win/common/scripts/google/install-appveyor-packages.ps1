
# Install all the necessary Appveyor Tools for the Box.

$PackerScriptsDir = $Env:PACKER_SCRIPTS_DIR

.  $PackerScriptsDir/windows-env.ps1

$PsVersionMajor = $PSVersionTable.PSVersion.Major

function Run-AppveyorProvisionScript (
[string] $ScriptName,
[string] $Description)
{
    Write-Output "---------------------------"
    Write-Output "Script: $ScriptName - $Description"
    # Pause to Ensure script title is printed before any error output.
    Start-Sleep -Seconds 5

    & $ScriptName
    Write-Output "---------------------------"
    Write-Output ""

}

#Start-Sleep -Seconds 6000

Write-Output "Importing some useful modules"
Import-Module $PackerScriptsDir\path-utils.psm1

# Code derived from: https://github.com/appveyor/ci/blob/master/scripts/enterprise/disable_servermanager.ps1
Write-Output "---------------------------"
Write-Output "Disabling Server Manager auto-start" 
$serverManagerMachineKey = "HKLM:\SOFTWARE\Microsoft\ServerManager"
$serverManagerUserKey = "HKCU:\SOFTWARE\Microsoft\ServerManager"
if(Test-Path $serverManagerMachineKey) {
    Set-ItemProperty -Path $serverManagerMachineKey -Name "DoNotOpenServerManagerAtLogon" -Value 1
    Write-Output "Disabled Server Manager at logon for all users" 
}
if(Test-Path $serverManagerUserKey) {
    Set-ItemProperty -Path $serverManagerUserKey -Name "CheckedUnattendLaunchSetting" -Value 0
    Write-Output "Disabled Server Manager for current user" 
}
Write-Output "---------------------------"

# disable scheduled task
schtasks /Change /TN "\Microsoft\Windows\Server Manager\ServerManager" /DISABLE

# Code derived from: https://github.com/appveyor/ci/blob/master/scripts/enterprise/disable_wer.ps1
Write-Output "---------------------------"
Write-Output "Disabling Windows Error Reporting (WER)" 
$werKey = "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting"
Set-ItemProperty $werKey -Name "ForceQueue" -Value 1

if(Test-Path "$werKey\Consent") {
    Set-ItemProperty "$werKey\Consent" -Name "DefaultConsent" -Value 1
}
Write-Output "Windows Error Reporting (WER) dialog has been disabled." 
Write-Output "---------------------------"

# Code derived from: https://github.com/appveyor/ci/blob/master/scripts/enterprise/disable_ie_esc.ps1
Write-Output "---------------------------"
Write-Output "Disabling Internet Explorer ESC" 
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
if((Test-Path $AdminKey) -or (Test-Path $UserKey)) {
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
    Write-Output "IE Enhanced Security Configuration (ESC) has been disabled." 
}
Write-Output "---------------------------"

# Code derived from: https://github.com/appveyor/ci/blob/master/scripts/enterprise/update_winrm_allow_hosts.ps1
Write-Output "---------------------------"
Write-Output "WinRM - allow * hosts" 
cmd /c 'winrm set winrm/config/client @{TrustedHosts="*"}'
Write-Output "WinRM configured" 
Write-Output "---------------------------"

# Code derived from: https://github.com/appveyor/ci/blob/master/scripts/enterprise/disable_new_network_location_wizard.ps1
Write-Output "---------------------------"
New-Item         -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force
# Original script also specified this key, but get access denied - leave for the moment.
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NetworkLocationWizard" -Name "HideWizard" -Value 1 -Force
Write-Output "---------------------------"

# All these installation scripts are used as-is
Run-AppveyorProvisionScript -ScriptName  $PackerScriptsDir\enterprise\install_7zip.ps1 -Description 'Install 7zip'

Run-AppveyorProvisionScript -ScriptName  $PackerScriptsDir\enterprise\install_chocolatey.ps1 -Description 'Cadburys please'

Run-AppveyorProvisionScript -ScriptName  $PackerScriptsDir\enterprise\install_webpi.ps1 -Description 'Install Web Platform Installer'

Run-AppveyorProvisionScript -ScriptName  $PackerScriptsDir\enterprise\install_nuget.ps1 -Description 'Install Nuget'

#if ($PsVersionMajor -eq "3") {
#    Exit 0 
#}

Run-AppveyorProvisionScript -ScriptName  $PackerScriptsDir\enterprise\install_git.ps1 -Description 'Git over here mon'
Run-AppveyorProvisionScript -ScriptName  $PackerScriptsDir\enterprise\install_git_lfs.ps1 -Description 'Git over here Big mon' 

Run-AppveyorProvisionScript -ScriptName  $PackerScriptsDir\enterprise\add_ssh_known_hosts.ps1 -Description 'Add Known SSH Hosts'

Run-AppveyorProvisionScript -ScriptName  $PackerScriptsDir\enterprise\install_appveyor_build_agent.ps1 -Description 'Install Appveyor Build Agent'

Run-AppveyorProvisionScript -ScriptName  $PackerScriptsDir\enterprise\install_ruby.ps1 -Description 'Install Ruby (multiple versions)'

Write-Output "---------------------------"
Write-Output "Install Autologon" 
choco install -y autologon
Write-Output "Autologon Installed"
Write-Output "---------------------------"

# Code derived from: https://github.com/appveyor/ci/blob/master/scripts/enterprise/set_gce_build_agent_mode.ps1
Write-Output "---------------------------"
Write-Output "Setting GCE Build Agent Mode" 
Set-ItemProperty "HKLM:\SOFTWARE\AppVeyor\Build Agent\" -Name "Mode" -Value "GCE"
Write-Output "GCE Build Agent Mode Set" 
Write-Output "---------------------------"

# Code derived from: https://github.com/appveyor/ci/blob/master/scripts/enterprise/add_appveyor_build_agent_to_auto_run.ps1
# Use HKLM instead of HKCU as there were issues getting it working under GCE environment (sysprep perhaps?)
Write-Output "---------------------------"
Write-Output "Setting Appveyor Agent to AutoRun" 
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AppVeyor.BuildAgent" `
  -Value 'c:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -noprofile -sta -WindowStyle Hidden  -File "C:\Packer\Scripts\start-appveyor-agent.ps1"'
Write-Output "Appveyor Agent AutoRun Key Set" 
Write-Output "---------------------------"

Write-Output "Appveyor Apps Installation Completed" 
