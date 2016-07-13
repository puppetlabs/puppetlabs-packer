$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

$PackageDir = 'A:\'

$WinlogonPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
Remove-ItemProperty -Path $WinlogonPath -Name AutoAdminLogon -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $WinlogonPath -Name DefaultUserName -ErrorAction SilentlyContinue

$packageFile = Get-ChildItem -Path $PackageDir | ? { $_.Name -match '.package.ps1$'} | Select-Object -First 1
if ($packageFile -eq $null) {
  Write-Warning "No boxstarter packages found in $PackageDir"
  return
}

iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/mwrock/boxstarter/master/BuildScripts/bootstrapper.ps1'))
Get-Boxstarter -Force

# Cleanup after boxstarter install
Remove-Item -Path "$($Env:USERPROFILE)\Desktop\Boxstarter Shell.lnk" -Confirm:$false -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item -Path "$($Env:APPDATA)\Microsoft\Windows\Start Menu\Programs\Boxstarter" -Recurse -Confirm:$false -Force -ErrorAction SilentlyContinue | Out-Null

$secpasswd = ConvertTo-SecureString "puppet" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("puppet", $secpasswd)

Import-Module $env:appdata\boxstarter\boxstarter.chocolatey\boxstarter.chocolatey.psd1
Install-BoxstarterPackage -PackageName ($packageFile.Fullname) -Credential $cred
