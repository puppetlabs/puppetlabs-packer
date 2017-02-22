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
$WindowsVersion = (Get-WmiObject win32_operatingsystem).version

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

# Common variable definitions for packer installations and staging

$PackerStaging = "C:\Packer"
$PackerDownloads = "$PackerStaging\Downloads"
$PackerPuppet = "$PackerStaging\puppet"
$SysInternals = "$PackerStaging\SysInternals"
$CygwinDownloads = "$PackerDownloads\Cygwin"
$PackerLogs = "$PackerDownloads\Logs"

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
        Write-Host "Max Attempts exceeded"
        throw "Download aborting"
      } else {
        $retrycount++
        Write-Host "Download Failed $retrycount of $maxretries - Sleeping $delay"
        Start-Sleep -Seconds $delay
      }
    }
  }
}

# Helper function to set both User and Default User registry key.
# This assumes the default user hive has been mounted as HKLM\DEFUSER
# As noted elsewhere, the intention to to replace all Powershell registry calls with Puppet code

Function Set-UserKey($key,$valuename,$reg_type,$data) {
  Write-Host "Setting Default User registry entry: $key\$valuename"
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
        echo $null > $file
    }
}

# Helper function to disable all sleep timeouts on the windows box.
# Adding on the suspicion that the Cumulative Updates for Win-10 are allowing
# standby sleep to activate during the long download.

Function Disable-PC-Sleep
{
  Write-Host "Disabling all Sleep timers"
  Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateFileSizePercent' -Value 0
  Set-ItemProperty -Path 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateEnabled' -Value 0
  Try
  {
    # Move it to high performance mode.
    $HighPerf = powercfg -l | %{if($_.contains("High performance")) {$_.split()[3]}}
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

# Helper function to perform a final reboot.
# This should help pick up any "trailing" windows updates as it appears that
# There are still some missing updates.

Function Do-Packer-Final-Reboot
{
  if (-not (Test-Path "A:\Final.Reboot"))
  {
    Touch-File "A:\Final.Reboot"
    Invoke-Reboot
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

  Write-Host "Downloading $PatchFilename"
  Download-File "$PatchUrl"  "$ENV:TEMP\$PatchFilename"
  Write-Host "Applying $PatchFilename Patch"
  Start-Process -Wait "wusa.exe" -ArgumentList "$ENV:TEMP\$PatchFilename /quiet /norestart"
  Write-Host "Patch Installed"
}
