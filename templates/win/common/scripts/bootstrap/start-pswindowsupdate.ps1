param (
    [string]$HyperVisor = "vmware"
)
$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1
$PackageDir = 'A:\'

$rundate = date
write-output "Script: start-pswindowsupdate.ps1 Starting at: $rundate"

# Create Packer Log Directories if they don't exist already.
Create-PackerStagingDirectories
if (-not (Test-Path "$PackerScripts\windows-env.ps1" )) {
  Copy-Item A:\windows-env.ps1 $PackerScripts\windows-env.ps1
}

# Check if we are a Core platform-packages
If ( $WindowsServerCore ) {
  Install-CoreStartupWorkaround
}

# Enable WSUS - this is being put at the top of the script deliberately as a recycle of wuauserv is
# required - this most reliable way to do this is with a reboot so we want to get this out the way first
# to prevent windows update starting anything.
# Windows-10/2016 seem to consistenly break on WSUS, so disable WSUS completely for these.
if ($WindowsVersion -like $WindowsServer2016) {
  Write-Output "Bypassing WSUS - Go Direct to Microsoft for updates"
}
else {
  Enable-UpdatesFromInternalWSUS
}

if (-not (Test-Path "$PackerLogs\HyperVisorExtensions.installed")) {
  Write-Output "Installing HyperVisor ($HyperVisor) Extensions/Tools"

  # This is a Windows 10 only workaround to make sure the trusted installer is actually running.
  # This needs to be done early on in the initialisation sequence well before we apply updates.
  # Not certain, but this appears to improve the reliability of the windows update.
  if ($WindowsVersion -Like $WindowsServer2016) {
    Set-Service "trustedinstaller" -StartupType Automatic -ErrorAction SilentlyContinue
  }

  if (($WindowsVersion -Like $WindowsServer2016) -or ($WindowsVersion -Like $WindowsServer2012R2)) {
    # Block Windows Store updates during the build process (until GPO policies are in place)
    Write-Host "Stop Windows Store Updates"
    reg add HKLM\Software\Policies\Microsoft\Windows\CloudContent /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f
    reg add HKLM\Software\Policies\Microsoft\WindowsStore /v AutoDownload /t REG_DWORD /d 2 /f
    reg add HKLM\Software\Policies\Microsoft\WindowsStore /v RemoveWindowsStore /t REG_DWORD /d 1 /f
  }

  switch ($HyperVisor) {
    "vmware" {
      # VMWare installs only
      # Install VMWare tools at this point as we will need to reboot afterwars.
      Write-Output "Installing VMWare Tools"
      if ("$ARCH" -eq "x86") {
        $VMToolsInstaller = "E:\setup.exe"
      } else {
        $VMToolsInstaller = "E:\setup64.exe"
      }
      $vproc = Start-Process "$VMToolsInstaller" @SprocParms -ArgumentList '/s /v "/qn REBOOT=R ADDLOCAL=ALL REMOVE=Hgfs"'
      $vproc.WaitForExit()
      break
    }
    "virtualbox" {
      # VirtualBox installs only
      # Install Virtual Box extensions
      Write-Output "Install VirtualBox Tools cert"
      $vproc = Start-Process certutil  @SprocParms -ArgumentList '-addstore -f "TrustedPublisher" A:\oracle-cert-1.cer'

      Write-Output "Installing Virtual Box Extensions"
      $vproc = Start-Process "E:\VBoxWindowsAdditions.exe" @SprocParms -ArgumentList '/S'
      $vproc.WaitForExit()
      break
    }
  }
  Touch-File "$PackerLogs\HyperVisorExtensions.installed"
  Write-Output "Forcing Reboot to fully install Hypervisor extension/toolset and restart wuauserv"
  Invoke-Reboot
}

if (-not (Test-Path "$PackerLogs\PrivatiseNetAdapters.installed")) {
  # Set all network adapters Private
  Write-Output "Set all network adapters private"
  if (($WindowsVersion -like $WindowsServer2008) -or ($WindowsVersion -like $WindowsServer2008r2)) {

    # This hack was obtained to set the network interface private for PS2 platforms
    # Source https://blogs.msdn.microsoft.com/dimeby8/2009/06/10/change-unidentified-network-from-public-to-work-in-windows-7/
    #
    Write-Output "Using Workaround Method"
    $NLMType = [Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B')
    $INetworkListManager = [Activator]::CreateInstance($NLMType)
    $NLM_ENUM_NETWORK_CONNECTED  = 1
    $NLM_NETWORK_CATEGORY_PUBLIC = 0x00
    $NLM_NETWORK_CATEGORY_PRIVATE = 0x01
    $INetworks = $INetworkListManager.GetNetworks($NLM_ENUM_NETWORK_CONNECTED)
    foreach ($INetwork in $INetworks)
    {
        $Name = $INetwork.GetName()
        $Category = $INetwork.GetCategory()
        Write-Output "Network $Name, Category $Category"
        if ($INetwork.IsConnected -and ($Category -eq $NLM_NETWORK_CATEGORY_PUBLIC) -and ($Name -eq "Unidentified network" -or $Name -eq "Network"))
        {
          Write-Output "Setting Network Private"
            $INetwork.SetCategory($NLM_NETWORK_CATEGORY_PRIVATE)
        }
      }
  }
  else {
      # Use cmdlet to run through network interfacen and set them private.
      New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force -ErrorAction SilentlyContinue
      Set-NetConnectionProfile  -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex -NetworkCategory Private
  }
  Touch-File "$PackerLogs\PrivatiseNetAdapters.installed"
}

# Install latest .Net package prior to any windows updates.
Install-DotNetLatest

if (-not (Test-Path "$PackerLogs\7zip.installed")) {
  # Download and install 7za now as its needed here and is useful going forward.
  $SevenZipInstaller = "7z1604-$ARCH.exe"
  Write-Output "Installing 7zip $SevenZipInstaller"
  Download-File "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/7zip/$SevenZipInstaller"  "$Env:TEMP\$SevenZipInstaller"
  Start-Process -Wait "$Env:TEMP\$SevenZipInstaller" @SprocParms -ArgumentList "/S"
  Touch-File "$PackerLogs\7zip.installed"
  Write-Output "7zip Installed"
}

if (-not (Test-Path "$PackerLogs\PSWindowsUpdate.installed")) {
  # Download and install PSWindows Update Modules.
  Download-File "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/pswindowsupdate/PSWindowsUpdate.1.6.1.1.zip" "$Env:TEMP/pswindowsupdate.zip"
  mkdir -Path "$Env:TEMP\PSWindowsUpdate"
  $zproc = Start-Process "$7zip" @SprocParms -ArgumentList "x $Env:TEMP/pswindowsupdate.zip -y -o$PackerStaging"
  $zproc.WaitForExit()
  Touch-File "$PackerLogs\PSWindowsUpdate.installed"
}

# Need to guard against system going into standby for long updates
Write-Output "Disabling Sleep timers"
Disable-PC-Sleep

# Run the (Optional) Installation Package File.
if (Test-Path "A:\platform-packages.ps1")
{
  & "A:\platform-packages.ps1"
}
else {
  Write-Warning "No additional packages found in $PackageDir"
}

# Run Windows Update - this will repeat as often as needed through the Invoke-Reboot cycle.
# When no more reboots are needed, the script falls through to the end.
Write-Output "Searching for Windows Updates"
if ($WindowsVersion -like $WindowsServer2016) {
  Write-Output "Disabling some more Windows Update (10) parameters"
  Write-Output "Disable seeding of updates to other computers via Group Policies"
  force-mkdir "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
  Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" 0
}

Write-Output "Using PSWindowsUpdate module"
Import-Module "$PackerStaging\PSWindowsUpdate\PSWindowsUpdate.psd1"

# Repeat this command twice to ensure any interrupted downloads are re-attempted for install.
# Windows-10 in particular seems to be affected by intermittency here - so try and improve reliability
$Attempt = 1
do {
  Write-Output "Windows Update Pass $Attempt"
  try {
    # Need to handle Powershell 2 compatibility issue here - Unblock-File is used but not
    # present in PS2
    if ($psversiontable.psversion.major -eq 2) {
      Get-WUInstall -AcceptAll -UpdateType Software -IgnoreReboot -Erroraction SilentlyContinue
      Write-Output "Running PSWindows Update - Ignoring errors (PS2)"
    }
    else {
      Write-Output "Running PSWindows Update"
      Get-WUInstall -AcceptAll -UpdateType Software -IgnoreReboot
    }
    if (Test-PendingReboot) { Invoke-Reboot }
  }
  catch {
    Write-Warning "ERROR updating Windows"
    # Code here to trap error and fall out of process dumping log.
  }
  $Attempt++
} while ($Attempt -le 2)

# Run the Application Package Cleaner
if (Test-Path "$PackerLogs\AppsPackageRemove.Required") {
  Write-Output "Running Apps Package Cleaner post windows update"
  Remove-AppsPackages -AppPackageCheckpoint AppsPackageRemove.Pass1
}

# Enable Remote Desktop (with reduce authentication resetting here again)
Write-Output "Enable Remote Desktop"
Enable-RemoteDesktop -DoNotRequireUserLevelAuthentication
netsh advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow

# Add WinRM Firewall Rule
Write-Output "Setting up winrm"
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

# WinRM Configuration.
Write-Output "Enable PS-Remoting -Force"
$enableArgs=@{Force=$true}
try {
 $command=Get-Command Enable-PSRemoting
  if($command.Parameters.Keys -contains "skipnetworkprofilecheck"){
      $enableArgs.skipnetworkprofilecheck=$true
  }
}
catch {
  $global:error.RemoveAt(0)
}
try {
  Enable-PSRemoting @enableArgs
}
catch {
  Write-Output "Ignoring PSRemoting Error"
}

Write-Output "Enable WSMandCredSSP"
Enable-WSManCredSSP -Force -Role Server

# NOTE - This is insecure but can be shored up in later customisation.  Required for Vagrant and other provisioning tools
Write-Output "WinRM Settings"
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
# Needed for Win-2008r2
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'
# Set service to start automatically (not delayed)
Set-Service "WinRM" -StartupType Automatic

Write-Output "WinRM setup complete"

# Clear reboot files as control is now transferred to Packer to complete configuration.
Clear-RebootFiles
