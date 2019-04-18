<#
  .SYNOPSIS
	Helper Scripts for Packer Build
  .DESCRIPTION
  Sets up a consistent environment for the Packer/Windows build provisioners and provides
  helpers as needed.
#>

# Placeholder Environment script for common variable definition.
$ErrorActionPreference = 'Continue'

# Defining set of constants for Windows version checking used throughout the code.
# Using Major/Minor versions only as listed in:
#   https://msdn.microsoft.com/en-gb/library/windows/desktop/ms724832%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
# These are intended to be checking using the "-like" comparison with these constants on the RHS of the test express
# The $WindowsVersion variable is also determined at this stage as its used in multiple scripts.
Set-Variable -Option Constant -Name WindowsServer2008   -Value "6.0.*"
Set-Variable -Option Constant -Name WindowsServer2008r2 -Value "6.1.*"
Set-Variable -Option Constant -Name WindowsServer2012   -Value "6.2.*"
Set-Variable -Option Constant -Name WindowsServer2012R2 -Value "6.3.*"
Set-Variable -Option Constant -Name WindowsServer2016   -Value "10.*"
$WindowsVersion = (Get-WmiObject win32_operatingsystem).version

# Collect additional Windows Installation Parameters - useful for various uses including platform verification
$NTVerKeyPath = "Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
$WindowsProductName = (Get-ItemProperty -Path "$NTVerKeyPath" -Name ProductName).ProductName
$WindowsEditionID = (Get-ItemProperty -Path "$NTVerKeyPath" -Name EditionID).EditionID

# InstallationType does not appear in Windows 2008 (Assume Server)
if ($WindowsVersion -Like $WindowsServer2008) {
  $global:WindowsInstallationType = "Server"
} else {
  $global:WindowsInstallationType = (Get-ItemProperty -Path "$NTVerKeyPath" -Name InstallationType).InstallationType
}

# ReleaseID is tricky as it only appears in later Windows 10 builds.
$WindowsReleaseIDObj = Get-ItemProperty -ErrorAction SilentlyContinue -Path "$NTVerKeyPath" -Name ReleaseID
if ($WindowsReleaseIDObj) {
  $global:WindowsReleaseID = $WindowsReleaseIDObj.ReleaseID
} else {
  $global:WindowsReleaseID = "N/A"
}

# Get Administrator SID
$WindowsAdminSID =  (Get-WmiObject win32_useraccount -Filter "Sid like 'S-1-5-21-%-500'").sid
# Crude Code to chose appropriate resonse for YesNo
$PrimaryLanguage = (Get-Culture).TwoLetterISOLanguageName
Switch ($PrimaryLanguage) {
  "fr"  {
    $global:AnswerPromptYes = "O"
    $global:TZTitle = "Fuseau horaire:"
    break
  }
  default {
    $global:AnswerPromptYes = "Y"
    $global:TZTitle = "Zone:"
    break 
  }
}

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
If (($PSVersionTable.PSVersion.Major) -eq 2 ) {
  # This delight was obtained from: http://www.leeholmes.com/blog/2008/07/30/workaround-the-os-handles-position-is-not-what-filestream-expected/
  # It is only relevant for Win-2008SP2 when running Powershell in elevated mode.
  # Which seems to be necessary to get Puppet and other things to run correctly.
  # Suspect this is due to the early (mis)implementation of UAC in Vista/Win-2008
  # BREAKING News - this is also breaking win-2008r2 (PS2)
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
$PuppetModulesPath = "$PackerPuppet\modules"
$PuppetHieradata = "$PackerPuppet\data"
$PackerScripts = "$PackerStaging\Scripts"
$SysInternals = "$PackerStaging\SysInternals"
$PackerLogs = "$PackerStaging\Logs"
$PackerConfig = "$PackerStaging\Config"
$CygwinDownloads = "$PackerDownloads\Cygwin"
$PackerPsModules = "$PackerStaging\PsModules"
$PackerAcceptance = "$PackerStaging\Acceptance"

# Load in the build parameters injected from the Packer Build.
$PackerBuildFile = "$PuppetHieradata\build.json"
if (Test-Path "$PuppetHieradata\build.json") {
  $PackerBuildData = Get-Content -Path "$PuppetHieradata\build.json"

  [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
  $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
  $Global:PackerBuildParams = $ser.DeserializeObject($PackerBuildData)
}

# For Puppet modules configuration
$ModulesPath = ''
$PuppetPath = "$ENV:PROGRAMFILES\Puppet Labs\Puppet\bin\puppet.bat"

$7zip = "$ENV:PROGRAMFILES\7-Zip\7z.exe"

if ($ENV:PROCESSOR_ARCHITECTURE -eq 'x86') {
  $ARCH = 'x86'
} else {
  $ARCH = 'x86_64'
}

# Work out what CYGDIR is and set it as a Windows Environment Variable
# Note - need seperate Prefix var for environment variables due to cygwin/git-for-win idiosyncrasies
if ($ARCH -eq 'x86') {
  $CygWinDir = "C:\cygwin"
  $CygEnvPrefix = "C:/cygwin"
} else {
  $CygWinDir = "C:\cygwin64"
  $CygEnvPrefix = "C:/cygwin64"
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

# Helper to create consistent staging directories.
Function Create-PackerStagingDirectories {
  if (-not (Test-Path "$PackerLogs/StagingDirectories.installed")) {
    Write-Output "Creating $PackerStaging and its associated directories"

    New-Item -ItemType Directory -Force -Path $PackerStaging

    New-Item -ItemType Directory -Force -Path $PuppetModulesPath
    New-Item -ItemType Directory -Force -Path $PuppetHieradata
    New-Item -ItemType Directory -Force -Path $PackerDownloads
    New-Item -ItemType Directory -Force -Path $CygwinDownloads
    New-Item -ItemType Directory -Force -Path $PackerConfig
    New-Item -ItemType Directory -Force -Path $PackerScripts
    New-Item -ItemType Directory -Force -Path $PackerPsModules
    New-Item -ItemType Directory -Force -Path $SysInternals
    New-Item -ItemType Directory -Force -Path $PackerAcceptance

    Touch-File "$PackerLogs/StagingDirectories.installed"
  }
}


# Function to download the packages we need - used in several scripts.
Function Download-File {
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

# Helper Function to set both User and Default User registry key.
# This assumes the default user hive has been mounted as HKLM\DEFUSER
# As noted elsewhere, the intention to to replace all Powershell registry calls with Puppet code
Function Set-UserKey($key,$valuename,$reg_type,$data) {
  Write-Output "Setting Default User registry entry: $key\$valuename"
  reg.exe ADD "HKLM\DEFUSER\$key" /v "$valuename" /t $reg_type /d $data /f
}

# Copy of Unix Touch command - useful for checkpointing w.r.t. Boxstarter
Function Touch-File {
  $file = $args[0]
  if($null -eq $file) {
    throw "No filename supplied"
  }

  if(Test-Path $file)
  {
    (Get-ChildItem $file).LastWriteTime = Get-Date
  }
  else
  {
    Write-Output "Touch File: $file created"
    Write-Output $null > $file
  }
}

# Helper Function to disable all sleep timeouts on the windows box.
# Adding on the suspicion that the Cumulative Updates for Win-10 are allowing
# standby sleep to activate during the long download.

Function Disable-PC-Sleep {
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

# Helper Function to install Windows/MS Patch.
# Downloads file to $TEMP and uses wusa to install it.
Function Install_Win_Patch {
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

# Helper Function to delete file, with try/catch to ignore errors.
# This Function is used in both the clean host and clean-disk scripts.
# Leaving Verbose options on in all cases so we can be certain files are being removed (IMAGES-684)
Function ForceFullyDelete-Path {
  param(
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [String]$Path,
  [String]$LogFile
  )

  process {
    try {
      if(Test-Path $Path) {
          Write-Output "Removing $Path" >> $LogFile 2>&1
          Takeown /d "$AnswerPromptYes" /R /f $Path >> $LogFile 2>&1
          Icacls $Path /grant:r "*${WindowsAdminSID}:(OI)(CI)F" /t /c >> $LogFile 2>&1
          Remove-Item $Path -Recurse -Force >> $LogFile 2>&1
        }
      }
      catch {
          Write-Output "Ignoring Error deleting: $Path - Continue" >> $LogFile 2>&1
      }
  }
}

# Helper Function set Windows Update to use the Internal Production WSUS Server
Function Enable-UpdatesFromInternalWSUS {
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

# Helper Function set Windows Update to use the Internal Production WSUS Server
Function Disable-WindowsAutoUpdate {
  if (-not (Test-Path "$PackerLogs\DisableWinAutoUpdate.installed")) {

    Write-Output "Disabling Windows AutoUpdate"

    reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 0 /f
    reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 2 /f
    reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "ScheduledInstallDay" /t REG_DWORD /d 0 /f
    reg.exe ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "ScheduledInstallTime" /t REG_DWORD /d 3 /f

    Touch-File "$PackerLogs/DisableWinAutoUpdate.installed"
  }
}


# Helper Function to install 7zip as a key package
Function Install-7ZipPackage {
  if (-not (Test-Path "$PackerLogs\7zip.installed")) {
    # Download and install 7za now as its needed here and is useful going forward.
    $SevenZipInstaller = "7z1604-$ARCH.exe"
    Write-Output "Installing 7zip $SevenZipInstaller"
    Download-File "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/7zip/$SevenZipInstaller"  "$Env:TEMP\$SevenZipInstaller"
    Start-Process -Wait "$Env:TEMP\$SevenZipInstaller" @SprocParms -ArgumentList "/S"
    Touch-File "$PackerLogs\7zip.installed"
    Write-Output "7zip Installed"
  }
}

# Helper Function to install latest .Net package appropriate for this platform
Function Install-DotNetLatest {
  if (-not (Test-Path "$PackerLogs\InstallDotNetLatest.installed"))
  {
    # Install .Net 4.7 for all platforms except Windows 2008 (.Net 4.6)
      if ($WindowsVersion -like $WindowsServer2008 ) {
        Write-Output "Installing .Net 4.6"
        $DotNetInstaller = "NDP46-KB3045557-x86-x64-AllOS-ENU.exe"
      }
      else {
        Write-Output "Installing .Net 4.7.2"
        $DotNetInstaller = "NDP472-KB4054530-x86-x64-AllOS-ENU.exe"
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
          Install_Win_Patch -PatchUrl "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/dotnet/$PreReqPatch"
        }
      }
      Download-File "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/dotnet/$DotNetInstaller" "$Env:TEMP/$DotNetInstaller"
      Start-Process -Wait "$Env:TEMP/$DotNetInstaller" -NoNewWindow -PassThru -ArgumentList "/passive /norestart"
  }
  Touch-File "$PackerLogs\InstallDotNetLatest.installed"
}

# This code lifted from https://github.com/W4RH4WK/Debloat-Windows-10
# Windows-10 only ?
Function Takeown-Registry($key) {
  # TODO does not work for all root keys yet
  switch ($key.split('\')[0]) {
      "HKEY_CLASSES_ROOT" {
          $reg = [Microsoft.Win32.Registry]::ClassesRoot
          $key = $key.substring(18)
      }
      "HKEY_CURRENT_USER" {
          $reg = [Microsoft.Win32.Registry]::CurrentUser
          $key = $key.substring(18)
      }
      "HKEY_LOCAL_MACHINE" {
          $reg = [Microsoft.Win32.Registry]::LocalMachine
          $key = $key.substring(19)
      }
  }

  # get Admin group
  $admins = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
  $admins = $admins.Translate([System.Security.Principal.NTAccount])

  # set owner
  $key = $reg.OpenSubKey($key, "ReadWriteSubTree", "TakeOwnership")
  $acl = $key.GetAccessControl()
  $acl.SetOwner($admins)
  $key.SetAccessControl($acl)

  # set FullControl
  $acl = $key.GetAccessControl()
  $rule = New-Object System.Security.AccessControl.RegistryAccessRule($admins, "FullControl", "Allow")
  $acl.SetAccessRule($rule)
  $key.SetAccessControl($acl)
}

Function Takeown-File($path) {
  takeown.exe /A /F $path
  $acl = Get-Acl $path

  # get Admin group
  $admins = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
  $admins = $admins.Translate([System.Security.Principal.NTAccount])

  # add NT Authority\SYSTEM
  $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($admins, "FullControl", "None", "None", "Allow")
  $acl.AddAccessRule($rule)

  Set-Acl -Path $path -AclObject $acl
}

Function Takeown-Folder($path) {
  Takeown-File $path
  foreach ($item in Get-ChildItem $path) {
      if (Test-Path $item -PathType Container) {
          Takeown-Folder $item.FullName
      } else {
          Takeown-File $item.FullName
      }
  }
}

Function Elevate-Privileges {
  param($Privilege)
  $Definition = @"
  using System;
  using System.Runtime.InteropServices;
  public class AdjPriv {
      [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
          internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr rele);
      [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
          internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);
      [DllImport("advapi32.dll", SetLastError = true)]
          internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);
      [StructLayout(LayoutKind.Sequential, Pack = 1)]
          internal struct TokPriv1Luid {
              public int Count;
              public long Luid;
              public int Attr;
          }
      internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
      internal const int TOKEN_QUERY = 0x00000008;
      internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
      public static bool EnablePrivilege(long processHandle, string privilege) {
          bool retVal;
          TokPriv1Luid tp;
          IntPtr hproc = new IntPtr(processHandle);
          IntPtr htok = IntPtr.Zero;
          retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
          tp.Count = 1;
          tp.Luid = 0;
          tp.Attr = SE_PRIVILEGE_ENABLED;
          retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
          retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
          return retVal;
      }
  }
"@
  $ProcessHandle = (Get-Process -id $pid).Handle
  $type = Add-Type $definition -PassThru
  $type[0]::EnablePrivilege($processHandle, $Privilege)
}

# While `mkdir -force` works fine when dealing with regular folders, it behaves
# strange when using it at registry level. If the target registry key is
# already present, all values within that key are purged.
# This is because mkdir is actually an wrapper function which includes New-Item with parameters that may not transfer over well to registry.
Function force-mkdir($path) {
  if (!(Test-Path $path)) {
      New-Item -ItemType Directory -Force -Path $path
  }
}

# Helper Function to remove Store/Apps packages that break sysprep (packages are not needed in our test env)
Function Remove-AppsPackages {
  param( [String]$AppPackageCheckpoint = "AppsPackageRemove.Pass1")

  if (-not (Test-Path "$PackerLogs\$AppPackageCheckpoint"))
  {
    Write-Output "Remove All Win-10 App/Packages to prevent Sysprep Issues"

    Write-Output "Elevating privileges for this process"
    do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

    Write-Output "Uninstalling default apps"
    $KeepAppList = @(
        # apps which cannot be removed using Remove-AppxPackage
        # Put in a match-all for any GUID type app as they are all
        # microsoft ones that should be left
        "[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}"
        "Microsoft\.BioEnrollment"
        "Microsoft\.MicrosoftEdge"
        "Microsoft\.Services\.Store\.Engagement"
        "Microsoft\.XboxGameCallableUI"
        "Microsoft\.XboxIdentityProvider"
        "Microsoft\.AAD.BrokerPlugin"
        "Microsoft\.AccountsControl"
        "Microsoft\.CredDialogHost"
        "Microsoft\.ECApp"
        "Microsoft\.FreshPaint"
        "Microsoft\.LockApp"
        "Microsoft\.MicrosoftStickyNotes"
        "Microsoft\.PPIProjection"
        "Microsoft\.WindowsCalculator"
        "Microsoft\.WindowsFeedback"
        "Microsoft\.Windows\.Apprep.ChxApp"
        "Microsoft\.Windows\.AssignedAccessLockApp"
        "Microsoft\.Windows\.CloudExperienceHost"
        "Microsoft\.Windows\.ContentDeliveryManager"
        "Microsoft\.Windows\.Cortana"
        "Microsoft\.Windows\.HolographicFirstRun"
        "Microsoft\.Windows\.OOBE.*"
        "Microsoft\.Windows\.ParentalControls"
        "Microsoft\.Windows\.PeopleExperienceHost"
        "Microsoft\.Windows\.Photos"
        "Microsoft\.Windows\.PinningConfirmationDialog"
        "Microsoft\.Windows\.SecHealthUI"
        "Microsoft\.Windows\.SecondaryTileExperience"
        "Microsoft\.Windows\.SecureAssessmentBrowser"
        "Microsoft\.Windows\.ShellExperienceHost"
        "Microsoft\.Windows\.Photos"
        "Microsoft\.WindowsStore"
        "Microsoft\.Net\..*"
        "Microsoft\.VCLibs\..*"
        "windows\.immersivecontrolpanel"
        "Windows\.ContactSupport"
        "Windows\.PrintDialog"
        "Microsoft\.Advertising\.Xaml"
        "InputApp"
    )

    Get-AppXPackage -Allusers |
      Where-Object {$_.Name -notmatch ($KeepAppList -join '|') -and -not $_.IsFramework} |
      ForEach-Object {

        $AppName = $_.Name
        $AppFullName = $_.PackageFullName
        Write-Output "Trying to remove $AppName ($AppFullName)"

        # Note - need to encase package removals in try catch to avoid loop fallout
        # For some reason, the SilentlyContinue doesn't always appear to be honoured.
        try {
          # Note - Deliberately removing first for the User then All users is intentional
          # due to the unique way that Microsoft Handles Apps and Sysprep.
          # Sarc aside - Windows.messaging doesn't remove correctly unless this is done.
          Write-Output "Removing $AppName for User"
          Remove-AppxPackage -Package $AppFullName -ErrorAction SilentlyContinue

          Write-Output "Removing $AppName for All Users"
          Remove-AppxPackage -Package $AppFullName -AllUsers -ErrorAction SilentlyContinue
        }
        catch {
          Write-Output "Ingoring Package Removal error"
        }

        try {
          Write-Output "Removing Provisioned $AppName"
          Get-AppXProvisionedPackage -Online |
            Where-Object DisplayName -EQ $AppName |
            Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        }
        catch {
          Write-Output "Ignoring errors in provisioned pkgremoval for $AppName"
        }
    }

    # Specials for the tricky ones
    Get-AppXPackage -Name Microsoft.Windows.Cortana |
        ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"} -ErrorAction SilentlyContinue

    Touch-File "$PackerLogs\$AppPackageCheckpoint"
  }
}

# Helper Function to test for Pending Reboot
# This is modelled from: https://github.com/mwrock/boxstarter/blob/master/Boxstarter.Bootstrapper/Get-PendingReboot.ps1
# but only tests the current system and is simplied for packer environment (e.g. Domain & SCCM not evaluated)
Function Test-PendingReboot {

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
    }
  }

  ## Query WUAU from the registry
  $RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")
  if ($RegWUAURebootReq.sNames -contains "RebootRequired") {
    $WUAURebootReq = $true
  }

  ## Query PendingFileRenameOperations from the registry
  $RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\Session Manager\","PendingFileRenameOperations")
  $RegValuePFRO = $RegSubKeySM.sValue

  ## Query ComputerName and ActiveComputerName from the registry
  $ActCompNm = $WMI_Reg.GetStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\","ComputerName")
  $CompNm = $WMI_Reg.GetStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\","ComputerName")

  If ($ActCompNm -ne $CompNm)  {
    $CompPendRen = $true
  }

  ## If PendingFileRenameOperations has a value set $RegValuePFRO variable to $true
  If ($RegValuePFRO) {
    $PendFileRename = $true
  }

  $RebootPending = ($CompPendRen -or $CBSRebootPend -or $WUAURebootReq -or $PendFileRename)
  if ($RebootPending) {
    return $true
  }
  # Drop out and don't reboot.
  Write-Host "Reboot is not needed"
  return $false
}

# Helper Function to perform a reboot and continue the windows update process.
Function Invoke-Reboot {
  $shutdate = Get-Date
  Write-Output "Proceeding with Shutdown at: $shutdate"
  Write-Output "Using Shutdown command"
  shutdown /t 0 /r /f /c \"Packer Reboot\" /d p:4:1
  # Sleep here to stop any further command execution.
  Start-Sleep -Seconds 60
  Write-Output "Ok - we still havent shutdown lets drop this session completely"
  # This will stop this script and the parent scripts
  $host.SetShouldExit(0)
}

# Helper Function (from Boxstarter) to enable remote desktop
Function Enable-RemoteDesktop {
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

# Helper Function to install PS Windows Update - mainly for Appveyor Installs
Function Install-PSWindowsUpdate {

  $webDeployURL="https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc/file/41459/47/PSWindowsUpdate.zip"
  $zipPath="$($env:USERPROFILE)\Downloads\PSWindowsUpdate.zip"
  $targetDir="C:\Windows\System32\WindowsPowerShell\v1.0\Modules\"
  $explorerExe = "$env:windir\explorer.exe"
  $FileExists = Test-Path $explorerExe

  Write-Output "Starting PSWindowsUpdate module installation`n"

  (New-Object System.Net.WebClient).DownloadFile($webDeployURL, $zipPath)

  If ($FileExists -eq $False) {
    Write-Output "We have Identified your OS as Server Core`n"
    [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") > $null
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $targetDir)
  }
  Else {
    Write-Output "We have Identified your OS as Server with graphical UI`n"
    $shell = new-object -com shell.application
    $zipFile = $shell.NameSpace($zipPath)
    $destinationFolder = $shell.NameSpace($targetDir)
    $copyFlags = 0x00
    $copyFlags += 0x04 # Hide progress dialogs
    $copyFlags += 0x10 # Overwrite existing files
    $destinationFolder.CopyHere($zipFile.Items(), $copyFlags)
  }

  Write-Output "Ended PSWindowsUpdate Installation`n"
}

# Helper to import PsWindowsUpdate Module.
Function Import-PsWindowsUpdateModule {

  # Using PS Version checking here as need slightly different import methods for
  # the version - see notes associated with each branch below.

  if ($psversiontable.psversion.major -eq 2)
  {
    # Powershell 2.0 requires the use of the "Import-Module" command, whereas later versions
    # auto-import provided the PSModulePath env variable contains the module path.
    # Also set this alias for PS2 removes a benign error that causes Pester to barf.
    Write-Output "Importing PSWindowsUpdate module - PS2"
    Set-Alias -Name Unblock-File -Scope Global -Value Get-ChildItem
    Import-Module -Global -Name "$PackerPsModules\PSWindowsUpdate\PSWindowsUpdate.psd1"
  } else {
    # PS3+ uses auto import based on the PSModulesPath
    # Also because 2.0.0.4 uses an assembly .dll for the functionality, the update
    # to PSModulesPath is essential - just using the import command gives a
    # runtime reference error.
    Write-Output "Adding $PackerPsModules to PsModulePath for this session PS3+"
    $Env:PSModulePath += ";$PackerPsModules"
  }
}

#Helper Function to handle the various OS dependant shutdown conditions.
Function Shutdown-PackerBuild {

  # Remove the pagefile
  Write-Output "Removing page file.  Recreates on next boot"
  reg.exe ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"    /v "PagingFiles" /t REG_MULTI_SZ /f /d """"
  # Ensure pagefile is created again at reboot (and managed automatically)
  $System = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
  $System.AutomaticManagedPagefile = $true
  $System.Put()

  Write-Output "Bye Bye - Shutting Down"
  shutdown /s /t 1 /c \"Packer Shutdown\" /f /d p:4:1
}
