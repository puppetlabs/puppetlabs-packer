# Arm host for final boot
# Setup Run-Once Keys and also the immediate configuration that is needed to support
# configuring machine post vmpooler cloning

$ErrorActionPreference = 'Stop'

# Windows version checking logic is copied here as its not present by Default
# on the installed system (might be an idea to change this in the future)
Set-Variable -Option Constant -Name WindowsServer2008   -Value "6.0.*"
Set-Variable -Option Constant -Name WindowsServer2008r2 -Value "6.1.*"
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

# Arm machine using RunOnce Keys
Write-Output "Arming machine for first-run"
reg import C:\Packer\Config\vmpooler-clone-arm-runonce.reg

# Make sure NetBios is disabled on the host to avoid netbios name collision at first boot.
# Also disable VMWare USB Arbitration service (ignore errors if it is not there)
Set-Service "lmhosts" -StartupType Disabled
Set-Service "netbt" -StartupType Disabled
Set-Service "VMUSBArbService" -StartupType Disabled  -ErrorAction SilentlyContinue

# Remove the pagefile
Write-Output "Removing page file.  Recreates on next boot"
reg.exe ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"    /v "PagingFiles" /t REG_MULTI_SZ /f /d """"

# Ensure pagefile is created again at reboot (and managed automatically)
$System = GWMI Win32_ComputerSystem -EnableAllPrivileges
$System.AutomaticManagedPagefile = $true
$System.Put()

# End
