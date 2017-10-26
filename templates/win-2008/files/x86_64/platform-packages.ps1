$ErrorActionPreference = "Stop"

. A:\windows-env.ps1

# Make sure network connection is private
Write-Output "Setting network adapters to private"
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$connections = $networkListManager.GetNetworkConnections()

if (-not (Test-Path "$PackerLogs\NET35.Installed"))
{
  # Install .Net 3.5.1
  Write-Output ".Net 3.5.1"
  Download-File "http://buildsources.delivery.puppetlabs.net/windows/win-2008-ps2/dotnetfx35setup.exe"  "$ENV:TEMP\dotnetfx35setup.exe"
  Start-Process -Wait "$ENV:TEMP\dotnetfx35setup.exe" -ArgumentList "/q"
  Write-Output ".Net 3.5.1 Installed"
  Touch-File "$PackerLogs\NET35.Installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

if (-not (Test-Path "$PackerLogs\WinUpdate.Installed"))
{
  # Install .Net 3.5.1
  Write-Output "Updating Windows Update agent"
  Download-File "http://buildsources.delivery.puppetlabs.net/windows/win-2008-ps2/windowsupdateagent30-x64.exe"  "$ENV:TEMP\windowsupdateagent30-x64.exe"
  Start-Process -Wait "$ENV:TEMP\windowsupdateagent30-x64.exe" -ArgumentList "/q"
  Write-Output "Updating Windows Update agent"
  Touch-File "$PackerLogs\WinUpdate.Installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

if (-not (Test-Path "$PackerLogs\Win2008.Patches"))
{
  $patches = @(
    'http://download.windowsupdate.com/d/msdownload/update/software/secu/2016/04/windows6.0-kb3153199-x64_ff7991c9c3465327640c5fdf296934ac12467fd0.msu',
    "http://download.windowsupdate.com/d/msdownload/update/software/secu/2016/04/windows6.0-kb3145739-x64_918212eb27224cf312f865e159f172a4b8a75b76.msu"
  )
  $patches | % { Install_Win_Patch -PatchUrl $_ }

  Touch-File "$PackerLogs\Win2008.Patches"
  if (Test-PendingReboot) { Invoke-Reboot }
}
