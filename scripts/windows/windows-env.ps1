# Placeholder Environment script for common variable definition.
$ErrorActionPreference = 'Stop'

# Defining set of constants for Windows version checking used throughout the code.
# Using Major/Minor versions only as listed in:
#   https://msdn.microsoft.com/en-gb/library/windows/desktop/ms724832%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
# These are intended to be checking using the "-like" comparison with these constants on the RHS of the test express
# The $WindowsVersion variable is also determined at this stage as its used in multiple scripts.
Set-Variable -Option Constant -Name WindowsServer2008   -Value "6.0.*"
Set-Variable -Option Constant -Name WindowsServer2008r2 -Value "6.1.*"
Set-Variable -Option Constant -Name WindowsServer2012   -Value "6.2.*"
Set-Variable -Option Constant -Name WindowsServer2016   -Value "10.*"
$WindowsVersion = (Get-WmiObject win32_operatingsystem).version

# Test to see if we are Core Version or not.
# Core installation (no GUI). While there is a more exact WMI query to determine this, checking to see
# if windows explorer installed is an equally valid check for Windows-2012r2 etc.
# see https://serverfault.com/questions/529124/identify-windows-2012-server-core#
if (Test-Path "$env:windir\explorer.exe") {
  Set-Variable -Option Constant -Name WindowsServerCore -Value $false
}
else {
  Set-Variable -Option Constant -Name WindowsServerCore -Value $true
}

If ($WindowsVersion -like $WindowsServer2008) {
  # This delight was obtained from: http://www.leeholmes.com/blog/2008/07/30/workaround-the-os-handles-position-is-not-what-filestream-expected/
  # It is only relevant for Win-2008SP2 when running Powershell in elevated mode.
  # Which seems to be necessary to get Puppet and other things to run correctly.
  # Suspect this is due to the early (mis)implementation of UAC in Vista/Win-2008
  $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetField"
  $objectRef = $host.GetType().GetField("externalHostRef", $bindingFlags).GetValue($host)
  $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetProperty"
  $consoleHost = $objectRef.GetType().GetProperty("Value", $bindingFlags).GetValue($objectRef, @())
  [void] $consoleHost.GetType().GetProperty("IsStandardOutputRedirected", $bindingFlags).GetValue($consoleHost, @())
  $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetField"
  $field = $consoleHost.GetType().GetField("standardOutputWriter", $bindingFlags)
  $field.SetValue($consoleHost, [Console]::Out)
  $field2 = $consoleHost.GetType().GetField("standardErrorWriter", $bindingFlags)
  $field2.SetValue($consoleHost, [Console]::Out)
}

# For Startup files
$startup = "$env:appdata\Microsoft\Windows\Start Menu\Programs\Startup"

# Common variable definitions for packer installations and staging
$PackerStaging = "C:\Packer"
$PackerDownloads = "$PackerStaging\Downloads"
$PackerPuppet = "$PackerStaging\puppet"
$PackerScripts = "$PackerStaging\Scripts"
$SysInternals = "$PackerStaging\SysInternals"
$PackerLogs = "$PackerStaging\Logs"
$CygwinDownloads = "$PackerDownloads\Cygwin"

# For Puppet modules configuration
$ModulesPath = ''
$PuppetPath = "$ENV:PROGRAMFILES\Puppet Labs\Puppet\bin\puppet.bat"

$7zip = "$ENV:PROGRAMFILES\7-Zip\7z.exe"

if ($ENV:PROCESSOR_ARCHITECTURE -eq 'x86') {
  $ARCH = 'x86'
} else {
  $ARCH = 'x86_64'
}

# Cleanmgr Registry "SageSet" Value - setting this to "random" value and associated constants
$CleanMgrSageSet = "5462"
Set-Variable -Option Constant -Name CleanMgrStateFlags        -Value "StateFlags$CleanMgrSageSet"
Set-Variable -Option Constant -Name CleanMgrStateFlagClean    -Value 2
Set-Variable -Option Constant -Name CleanMgrStateFlagNoAction -Value 0

# Define common Start-Process params appropriate for running the install setups.
# Main one is -Wait (until setup is complete).
# PassThru and NoNewWindow also relevant to ensure any installer console output is properly captured
$SprocParms = @{'PassThru'=$true;
                'NoNewWindow'=$true
}

#--- FUNCTIONS ---#

# Function to stop transcript

function ExitScript([int]$ExitCode){
	Stop-Transcript
	exit $ExitCode
}

# Helper to create consistent staging directories.
function Create-PackerStagingDirectories {
  if (-not (Test-Path "$PackerStaging")) {
    Write-Host "Creating $PackerStaging"
    mkdir -Path $PackerStaging\puppet\modules
    mkdir -Path $PackerStaging\Downloads
    mkdir -Path $PackerStaging\Downloads\Cygwin
    mkdir -Path $PackerStaging\Init
    mkdir -Path $PackerStaging\Scripts
    mkdir -Path $PackerStaging\Logs
    mkdir -Path $PackerStaging\Sysinternals
  }
}


# Function to download the packages we need - used in several scripts.

function Download-File {
param (
  [string]$url,
  [string]$file
 )
  $downloader = new-object System.Net.WebClient
  $downloader.Proxy.Credentials=[System.Net.CredentialCache]::DefaultNetworkCredentials;

  Write-Output "Downloading $url to $file"
  $completed = $false
  $retrycount = 0
  $maxretries = 20
  $delay = 10
  while (-not $completed) {
    try {
      $downloader.DownloadFile($url, $file)
      $completed = $true
    } catch {
      if ($retrycount -ge $maxretries) {
        Write-Output "Max Attempts exceeded"
        throw "Download aborting"
      } else {
        $retrycount++
        Write-Output "Download Failed $retrycount of $maxretries - Sleeping $delay"
        Start-Sleep -Seconds $delay
      }
    }
  }
}

# Helper function to set both User and Default User registry key.
# This assumes the default user hive has been mounted as HKLM\DEFUSER
# As noted elsewhere, the intention to to replace all Powershell registry calls with Puppet code

Function Set-UserKey($key,$valuename,$reg_type,$data) {
  Write-Output "Setting Default User registry entry: $key\$valuename"
  reg.exe ADD "HKLM\DEFUSER\$key" /v "$valuename" /t $reg_type /d $data /f
}

# Copy of Unix Touch command - useful for checkpointing w.r.t. Boxstarter
Function Touch-File
{
    $file = $args[0]
    if($file -eq $null) {
        throw "No filename supplied"
    }

    if(Test-Path $file)
    {
        (Get-ChildItem $file).LastWriteTime = Get-Date
    }
    else
    {
        Write-Output $null > $file
    }
}

# Helper function to disable all sleep timeouts on the windows box.
# Adding on the suspicion that the Cumulative Updates for Win-10 are allowing
# standby sleep to activate during the long download.

Function Disable-PC-Sleep
{
  Write-Output "Disabling all Sleep timers"
  Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateFileSizePercent' -Value 0
  Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateEnabled' -Value 0
  Try
  {
    # Move it to high performance mode.
    $HighPerf = powercfg -l | ForEach-Object {if($_.contains("High performance")) {$_.split()[3]}}
    $CurrPlan = $(powercfg -getactivescheme).split()[3]
    if ($CurrPlan -ne $HighPerf) {powercfg -setactive $HighPerf}
    # Belt and braces - disable all timeouts.
    powercfg -x -monitor-timeout-ac 0
    powercfg -x -monitor-timeout-dc 0
    powercfg -x -disk-timeout-ac 0
    powercfg -x -disk-timeout-dc 0
    powercfg -x -standby-timeout-ac 0
    powercfg -x -standby-timeout-dc 0
    powercfg -x -hibernate-timeout-ac 0
    powercfg -x -hibernate-timeout-dc 0
  } Catch {
      Write-Warning -Message "Unable to set power plan to high performance"
  }
}

# Helper function to install Windows/MS Patch.
# Downloads file to $TEMP and uses wusa to install it.

Function Install_Win_Patch
{
  param(
    [Parameter(Mandatory = $true)]
    [String]$PatchUrl
  )

  $PatchFilename = $PatchUrl.Substring($PatchUrl.LastIndexOf("/") + 1)

  Write-Output "Downloading $PatchFilename"
  Download-File "$PatchUrl"  "$ENV:TEMP\$PatchFilename"
  Write-Output "Applying $PatchFilename Patch"
  Start-Process -Wait "wusa.exe" -ArgumentList "$ENV:TEMP\$PatchFilename /quiet /norestart"
  Write-Output "Patch Installed"
}

# Helper function to delete file, with try/catch to ignore errors.
# This function is used in both the clean host and clean-disk scripts.

Function ForceFullyDelete-Paths
{
  $filetodelete = $args[0]

  try {
    if(Test-Path $filetodelete) {
        Write-Output "Removing $filetodelete"
        Takeown /d Y /R /f $filetodelete
        Icacls $filetodelete /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
        Remove-Item $filetodelete -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
      }
    }
    catch {
        Write-Output "Ignoring Error deleting: $filetodelete - Continue"
    }
}

# Helper Function set Windows Update to use the Internal Production WSUS Server

Function Enable-UpdatesFromInternalWSUS
{
  if (-not (Test-Path "$PackerLogs\WSUSRedirect.installed")) {

    $WSUSServer = "http://imagingwsusprod.delivery.puppetlabs.net:8530"
    Write-Output "Setting Windows Update Server to $WSUSServer"

    reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"    /v "WUServer"       /t REG_SZ /d "$WSUSServer" /f
    reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"    /v "WUStatusServer" /t REG_SZ /d "$WSUSServer" /f
    reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 0 /f
    reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 2 /f
    reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "ScheduledInstallDay" /t REG_DWORD /d 0 /f
    reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "ScheduledInstallTime" /t REG_DWORD /d 3 /f
    reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "UseWUServer" /t REG_DWORD /d 1 /f

    Touch-File "$PackerLogs/WSUSRedirect.installed"
  }
}

# Helper function to perform a final reboot.
# This should help pick up any "trailing" windows updates as it appears that
# There are still some missing updates.

Function Do-Packer-Final-Reboot
{
  if (-not (Test-Path "$PackerLogs\Final.Reboot"))
  {
    Touch-File "$PackerLogs\Final.Reboot"
    Invoke-Reboot
  }
}

# Helper function to install latest .Net package appropriate for this platform
Function Install-DotNetLatest
{
  if (-not (Test-Path "$PackerLogs\InstallDotNetLatest.installed"))
  {
    # Install .Net 4.7 for all platforms except Windows 2008 (.Net 4.6)
      if ($WindowsVersion -like $WindowsServer2008 ) {
        Write-Output "Installing .Net 4.6"
        $DotNetInstaller = "NDP46-KB3045557-x86-x64-AllOS-ENU.exe"
      }
      else {
        Write-Output "Installing .Net 4.7"
        $DotNetInstaller = "NDP47-KB3186497-x86-x64-AllOS-ENU.exe"
        if ($WindowsVersion -like $WindowsServer2008r2 -or $WindowsVersion -like $WindowsServer2012 ) {
          # Win-2008r2 & 2012 need this patch installed.
          # This will fail silently if the patch is already installed.
          Write-Output "Installing Pre-Requisite for .Net 4.7"
          if ("$ARCH" -eq "x86") {
            $PreReqPatch = "Windows6.1-KB4019990-x86.msu"
          }
          else {
            $PreReqPatch = "Windows6.1-KB4019990-x64.msu"
          }
          Install_Win_Patch -PatchUrl "http://buildsources.delivery.puppetlabs.net/windows/dotnet/$PreReqPatch"
        }
      }
      Download-File "http://buildsources.delivery.puppetlabs.net/windows/dotnet/$DotNetInstaller" "$Env:TEMP/$DotNetInstaller"
      Start-Process -Wait "$Env:TEMP/$DotNetInstaller" -NoNewWindow -PassThru -ArgumentList "/passive /norestart"
  }
  Touch-File "$PackerLogs\InstallDotNetLatest.installed"
}


# Helper function to remove Store/Apps packages that break sysprep (packages are not needed in our test env)

Function Remove-AppsPackages
{
  Write-Output "Remove All Win-10 App/Packages to prevent Sysprep Issues"

  Import-Module Appx
  Import-Module Dism

  Write-Output "Removing AppxPackages"
  Get-AppxPackage -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue

  Write-Output "Removing Online Provisioned Packages"
  Get-AppXProvisionedPackage -online | Remove-AppxProvisionedPackage -online -ErrorAction SilentlyContinue

  if ("$ARCH" -eq "x86_64") {
    $SystemDir = "SysWOW64"
  } else {
    $SystemDir = "System32"
  }

  try {
    Write-Output "Stopping OneDrive"
    taskkill /f /im OneDrive.exe
  }
  catch {
    Write-Output "Ignoring OneDrive taskkill error"
  }

  try {
    Write-Output "Uninstalling OneDrive"
    $zproc = Start-Process "$env:SystemRoot\$SystemDir\OneDriveSetup.exe" -PassThru -NoNewWindow -ArgumentList "/uninstall"
    $zproc.WaitForExit()

    Remove-Item "$Env:UserProfile\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item "$Env:LocalAppData\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item "$Env:ProgramData\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item "C:\OneDriveTemp" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
  }
  catch {
    Write-Output "Ignoring OneDrive uninstall error"
  }

  if (Test-PendingReboot) { Invoke-Reboot }
}

# Helper Function to test for Pending Reboot
# This is modelled from: https://github.com/mwrock/boxstarter/blob/master/Boxstarter.Bootstrapper/Get-PendingReboot.ps1
# but only tests the current system and is simplied for packer environment (e.g. Domain & SCCM not evaluated)

function Test-PendingReboot {

  # Note - specifically use Write-Host here as output must be True/False
  Write-Host -ForegroundColor White "Testing for reboot conditions"
  ## Setting pending values to false to cut down on the number of else statements
  $CompPendRen,$PendFileRename,$WUAURebootReq = $false,$false
  ## Setting CBSRebootPend to null since not all versions of Windows has this value
  $CBSRebootPend = $null

  ## Querying WMI for build version
  $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ErrorAction Stop
  $Computer = $WMI_OS.CSName

  ## Making registry connection to the local/remote computer
  $HKLM = [UInt32] "0x80000002"
  $WMI_Reg = [WMIClass] "\\$Computer\root\default:StdRegProv"

  ## If Vista/2008 & Above query the CBS Reg Key
  If ([Int32]$WMI_OS.BuildNumber -ge 6001) {
    $RegSubKeysCBS = $WMI_Reg.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\")
    if ($RegSubKeysCBS.sNames -contains "RebootPending") {
      $CBSRebootPend = $true
      Write-Host -ForegroundColor Yellow "Component Based Servicing Needed"
    }
  }

  ## Query WUAU from the registry
  $RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")
  if ($RegWUAURebootReq.sNames -contains "RebootRequired") {
    $WUAURebootReq = $true
    Write-Host -ForegroundColor Yellow "Windows Update Reboot needed"
  }

  ## Query PendingFileRenameOperations from the registry
  $RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\Session Manager\","PendingFileRenameOperations")
  $RegValuePFRO = $RegSubKeySM.sValue

  ## Query ComputerName and ActiveComputerName from the registry
  $ActCompNm = $WMI_Reg.GetStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\","ComputerName")
  $CompNm = $WMI_Reg.GetStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\","ComputerName")

  If ($ActCompNm -ne $CompNm)  {
    $CompPendRen = $true
    Write-Host -ForegroundColor Yellow "Computer Rename"
  }

  ## If PendingFileRenameOperations has a value set $RegValuePFRO variable to $true
  If ($RegValuePFRO) {
    $PendFileRename = $true
    Write-Host -ForegroundColor Yellow "Pending File Rename"
  }

  $RebootPending = ($CompPendRen -or $CBSRebootPend -or $WUAURebootReq -or $PendFileRename)
  if ($RebootPending) {
    Write-Host -ForegroundColor Yellow "Reboot is Pending"
    return $true
  }
  # Drop out and don't reboot.
  Write-Host -ForegroundColor Green "Reboot is not needed"
  return $false
}

# Helper function to perform a reboot and continue the windows update process.
function Invoke-Reboot {
    Write-Output "Starting Reboot sequence"
    Write-Output "writing restart file"
    $restartScript="Call PowerShell -NoProfile -ExecutionPolicy bypass -command `"& A:\start-pswindowsupdate.ps1`""
    New-Item "$startup\packer-post-restart.bat" -type file -force -value $restartScript | Out-Null

	  shutdown /t 0 /r /f
    # Sleep here to stop any further command execution.
    Start-Sleep -Seconds 20
}

# Clear reboot files.
function Clear-RebootFiles {
  Remove-Item -Force -Path "$startup\packer-post-restart.bat"
  if ($WindowsServerCore ) {
    Remove-Item -Force -Path $PROFILE
  }
}

# Windows Core startup

function Install-CoreStartupWorkaround {
  if (-not (Test-Path "$PackerLogs\CoreStartupWorkaround.installed")) {
    Write-Output "Using Windows Core Reboot model"
    Set-ItemProperty `
             -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" `
             -Name Shell -Value "PowerShell.exe -NoExit"

    $profileDir = (Split-Path -Parent $PROFILE)
    if (!(Test-Path $profileDir)) {
      New-Item -Type Directory $profileDir
    }
    Copy-Item -Force A:\startup-profile.ps1 $PROFILE
    Touch-File $PackerLogs\CoreStartupWorkaround.installed
  }
}

# Helper function (from Boxstarter) to enable remote desktop
function Enable-RemoteDesktop {
  param(
       [switch]$DoNotRequireUserLevelAuthentication
  )

  Write-Output "Enabling Remote Desktop..."
  $obj = Get-WmiObject -Class "Win32_TerminalServiceSetting" -Namespace root\cimv2\terminalservices
  if($obj -eq $null) {
    Write-Output "Unable to locate terminalservices namespace. Remote Desktop is not enabled"
    return
  }
  try {
    $obj.SetAllowTsConnections(1,1) | out-null
  }
  catch {
    throw "There was a problem enabling remote desktop. Make sure your operating system supports remote desktop and there is no group policy preventing you from enabling it."
  }

  $obj2 = Get-WmiObject -class Win32_TSGeneralSetting -Namespace root\cimv2\terminalservices -ComputerName . -Filter "TerminalName='RDP-tcp'"

  if($obj2.UserAuthenticationRequired -eq $null) {
    Write-Output "Unable to locate Remote Desktop NLA namespace. Remote Desktop NLA is not enabled"
    return
  }
  try {
    if($DoNotRequireUserLevelAuthentication) {
      $obj2.SetUserAuthenticationRequired(0) | out-null
      Write-Output "Disabling Remote Desktop NLA ..."
    }
    else {
		  $obj2.SetUserAuthenticationRequired(1) | out-null
      Write-Output "Enabling Remote Desktop NLA ..."
    }
  }
  catch {
     throw "There was a problem enabling Remote Desktop NLA. Make sure your operating system supports Remote Desktop NLA and there is no group policy preventing you from enabling it."
  }
}
