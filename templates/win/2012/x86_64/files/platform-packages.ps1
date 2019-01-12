$ErrorActionPreference = "Stop"

. C:\Packer\Scripts\windows-env.ps1

Write-Output "Running Win-2012 Package Customisation"

if (-not (Test-Path "$PackerLogs\DesktopExperience.installed"))
{
  # Enable Desktop experience to get cleanmgr
  Write-Output "Enable Desktop-Experience"
  Add-WindowsFeature Desktop-Experience
  Touch-File "$PackerLogs\DesktopExperience.installed"
  if (Test-PendingReboot) { Invoke-Reboot }
}

# Servicing Stack Patches that don't get slipstreamed properly to be installed.
# Force reboot after each.

if (-not (Test-Path "$PackerLogs\Win2012-1.Patches"))
{
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/c/msdownload/update/software/updt/2015/04/windows8-rt-kb3003729-x64_e95e2c0534a7f3e8f51dd9bdb7d59e32f6d65612.msu"
  Touch-File "$PackerLogs\Win2012-1.Patches"
  Invoke-Reboot
}

if (-not (Test-Path "$PackerLogs\Win2012-2.Patches"))
{
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/updt/2015/09/windows8-rt-kb3096053-x64_930f557083e97c7e22e7da133e802afca4963d4f.msu"
  Touch-File "$PackerLogs\Win2012-2.Patches"
  Invoke-Reboot
}

if (-not (Test-Path "$PackerLogs\Win2012-3.Patches"))
{
  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/crup/2016/06/windows8-rt-kb3173426-x64_ecf1b38d9e3cdf1eace07b9ddbf6f57c1c9d9309.msu"
  Touch-File "$PackerLogs\Win2012-3.Patches"
  Invoke-Reboot
}

  # Note may also need this update: https://www.catalog.update.microsoft.com/Search.aspx?q=KB2919355
  # http://download.windowsupdate.com/d/msdownload/update/software/secu/2014/04/clearcompressionflag_3104315db9d84f6a2a56b9621e89ea66a8c27604.exe
  # http://download.windowsupdate.com/c/msdownload/update/software/crup/2014/02/windows8.1-kb2937592-x64_4abc0a39c9e500c0fbe9c41282169c92315cafc2.msu
  # http://download.windowsupdate.com/c/msdownload/update/software/secu/2014/04/windows8.1-kb2959977-x64_574ba2d60baa13645b764f55069b74b2de866975.msu
  # http://download.windowsupdate.com/c/msdownload/update/software/secu/2014/04/windows8.1-kb2934018-x64_234a5fc4955f81541f5bfc0d447e4fc4934efc38.msu
  # http://download.windowsupdate.com/c/msdownload/update/software/crup/2014/03/windows8.1-kb2938439-x64_3ed1574369e36b11f37af41aa3a875a115a3eac1.msu
  # http://download.windowsupdate.com/d/msdownload/update/software/crup/2014/02/windows8.1-kb2919355-x64_e6f4da4d33564419065a7370865faacf9b40ff72.msu
  # http://download.windowsupdate.com/d/msdownload/update/software/crup/2014/02/windows8.1-kb2932046-x64_6aee5fda6e2a6729d1fbae6eac08693acd70d985.msu

  if (-not (Test-Path "$PackerLogs\Win2012-4.Patches"))
  {
    # August 2016
    # https://social.technet.microsoft.com/Forums/en-US/36fb0752-d4a0-48ec-b5e1-217eec18ac20/stuck-checking-for-updates-server-2012-never-completes-the-operation?forum=winserver8gen
    # https://www.experts-exchange.com/questions/29019987/Windows-Server-2012-Standard-stuck-on-Checking-for-Updates.html
  
    Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/c/msdownload/update/software/updt/2016/07/windows8-rt-kb3179575-x64_76e44428b65d806c446638cf340db9d3da452063.msu"
    Touch-File "$PackerLogs\Win2012-4.Patches"
    Invoke-Reboot
  }
  
 # [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX]
 # "IsConvergedUpdateStackEnabled"=dword:00000000
 
#  [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings]
#  "UxOption"=dword:00000000
  
if (-not (Test-Path "$PackerLogs\Win2012-5.Patches"))
{
  # The April 11, 2017—KB4015551 (Monthly Rollup) is also needed as it contains
  # a critical patch that is unavailable separetly - see workaround discussion below. 
  # https://social.technet.microsoft.com/Forums/en-US/af1b44f6-02e7-4baa-99e3-da38d5e9b30d/server-2012-std-non-r2-windows-update-stuck-at-quotchecking-for-updatesquot?forum=winserver8gen
  # https://social.technet.microsoft.com/Forums/windowsserver/en-US/eff2be4b-120c-4f7c-b649-c7df2512b611/windows-update-checking-for-updates-kb3102810-windows-server-2012-not-r2?forum=winservergen

  Install_Win_Patch -PatchUrl "http://download.windowsupdate.com/d/msdownload/update/software/secu/2017/04/windows8-rt-kb4015551-x64_8e3457ab5a3108ede25df0240463ba16de7f87f8.msu"
  Touch-File "$PackerLogs\Win2012-5.Patches"
  Invoke-Reboot
}




