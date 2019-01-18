$ErrorActionPreference = "Stop"

. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-2012 Package Customisation"

# Used to install desktop features, but this appears to break Windows Update.
# See last suggestion in this reference:
# https://social.technet.microsoft.com/Forums/en-US/ae7cd1b1-59b2-4aa9-b0b2-d332243924dd/server-2012-stuck-on-checking-for-updates?forum=winserver8gen

# Servicing Stack Patches that don't get slipstreamed properly to be installed.
# Seems only one of these is actually needed.

if (-not (Test-Path "$PackerLogs\Win2012.Patches"))
{
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/crup/2016/06/windows8-rt-kb3173426-x64_ecf1b38d9e3cdf1eace07b9ddbf6f57c1c9d9309.msu"
  Touch-File "$PackerLogs\Win2012.Patches"
  Invoke-Reboot
}
