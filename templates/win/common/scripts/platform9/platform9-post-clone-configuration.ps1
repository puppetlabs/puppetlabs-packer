# Platform9 Post Clone configuration script
#

param (
    [string]$AdminUsername = "Administrator"
)

. C:\Packer\Scripts\windows-env.ps1

$rundate = date
write-output "Script: platform9-post-clone-configuration.ps1 Starting at: $rundate"

# Initialise and install cloudbase - no sysprep as we are already syspreped.

Write-Output "Starting Cloud-Init"
& "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\Python\Scripts\cloudbase-init.exe" --config-file "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf"
Write-Output "Cloudbase-Init Ended"

# Update machine password (and reset autologin)
Write-Output "Setting $AdminUsername Password"
net user $AdminUsername "$($PackerBuildParams.packer.qa_root_passwd_plain)"
autologon -AcceptEula $AdminUsername . "$($PackerBuildParams.packer.qa_root_passwd_plain)"

# Use BGInfo to paint the screen
if (-not $WindowsServerCore) {
  Write-Output "Setting up Run Key to run set-bginfo at login for the user".
  New-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Run" `
                   -Name "RunBgInfo" `
                   -PropertyType String `
                   -Value "c:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -File C:\Packer\Scripts\Set-Bginfo.ps1 -VMPlatform Platform9 >> C:\Packer\Logs\bginfo.log 2>&1"`
                   -Force `
                   -ErrorAction Continue
}

# Pin apps to taskbar as long as we aren't win-10/2016
if ($WindowsVersion -notlike $WindowsServer2016) {
  try {
    Write-Output "Pin Apps to Taskbar"
    & $PackerScripts\Pin-AppsToTaskBar.ps1
  }
  catch {
    Write-Output "Ignoring Pin App errors"
  }
}

Write-Output "Re-enable NETBios and WinRM Services"
Set-Service "lmhosts" -StartupType Automatic
Set-Service "netbt" -StartupType Automatic
Set-Service "WinRM" -StartupType Automatic

# Put a restart in to make sure host is renamed.
Write-Output "Restarting to allow host rename"
if ($WindowsVersion -like $WindowsServer2008R2 -or $WindowsVersion -like $WindowsServer2008) {
  shutdown /t 0 /r /f
}
else {
  Restart-Computer
}
