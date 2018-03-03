# GCE Host Startup Script.
# To make sure the correct parameters are set depending on the Powershell version for WMF 2.0/3.0
#
# Windows update is also done within this cycle as a pre-step before opening winrms
# This means that the startup script may take a significant period of time.

$PsVersionMajor = $PSVersionTable.PSVersion.Major
if ($PsVersionMajor -eq "2") {
    # This delight was obtained from: http://www.leeholmes.com/blog/2008/07/30/workaround-the-os-handles-position-is-not-what-filestream-expected/
    # It appears to be needed here again for PS2 Downgrade on Win-2008R2
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

    Write-Output "PS 2 Fix applied first."
}

. C:\Packer\Scripts\windows-env.ps1
# Override Stop due to PS2 issue with PSWindowsUpdate
$ErrorActionPreference = 'Continue'

$timestamp = Date
Write-Output "Script Starting: $timestamp" 
Write-Output "Powershell Version $PsVersionMajor"

if (-not (Test-Path "$PackerLogs\Execution.policy.$PsVersionMajor.installed" )) {

    Write-Output "Setting Execution Policy" 
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force -ErrorAction Continue
    }
    catch {
        Write-Output "Ignoring Execution Policy errors"
    }
    
    Touch-File "$PackerLogs\Execution.policy.$PsVersionMajor.installed"
}

if (-not (Test-Path "$PackerLogs\WindowsUpdates.$PsVersionMajor.installed" )) {
    If ((Get-Module -ListAvailable -Name PSWindowsUpdate) -ne $null) {
        Write-Output "PSWindowsUpdate module is installed. Skipping installation."
    }
    Else {
        Write-Output "Installing PS Windows Update."
        Install-PSWindowsUpdate
    }
    
    Write-Output "Starting Windows Update Cycle"
    Install-WindowsUpdates
    if (Test-PendingReboot) {
        Write-Output "Restarting"
        Restart-Computer -Force
        Exit 0
    }

    # Test for reboot - if not needed, fall through to the remainder.
    Touch-File "$PackerLogs\WindowsUpdates.$PsVersionMajor.installed"
}

winrm quickconfig -quiet 

switch ($PsVersionMajor) {

    "2" {
        Write-Output "Powershell 2 configuration" 
        Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 2048 

        if (-not (Test-Path "$PackerLogs\TLS12.installed" )) {
            
            # Enable TLS 1.1/1.2 protocols to allow .Net 3.5/PS 2 to avail of it.
            # This is important now that Github has disabled SSL/TLS 1.0
            Write-Output "Enabling TLS 1.1/1.2 for WMF 2.0"
            foreach($tlsversion in ("1","2") ){
                New-Item -Path "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.$tlsversion" -Force -ErrorAction Continue
                foreach($item in ("Client","Server") ) {
                    #Create a child-Key Called "Server" and other called "Client"
                    New-Item -Path "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.$tlsversion\$item" -Force -ErrorAction Continue
                    #Create on each child-key 2 DWORD "DisabledByDefault" with value 0 and "Enabled" with value 1
                    New-ItemProperty -Path  "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.$tlsversion\$item" -Name DisabledByDefault -PropertyType DWord -Value 0 -Force -ErrorAction Continue
                    New-ItemProperty -Path  "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.$tlsversion\$item"  -Name Enabled -PropertyType DWord -Value 1 -Force -ErrorAction Continue
                }
            }
            # These keys must be defined to enable PS2 to use the new registry defs above - the associated hotfixes to enable 1.2 for
            # .Net 3.5 are already in place but are ineffective until this is enabled.
            # https://support.microsoft.com/en-us/help/3154518/support-for-tls-system-default-versions-included-in-the-net-framework
            New-ItemProperty -Path  "HKLM:SOFTWARE\Microsoft\.NETFramework\v2.0.50727" -Name SystemDefaultTlsVersions -PropertyType DWord -Value 1 -Force -ErrorAction Continue
            New-ItemProperty -Path "HKLM:SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727" -Name SystemDefaultTlsVersions -PropertyType DWord -Value 1 -Force -ErrorAction Continue
            Touch-File "$PackerLogs\TLS12.installed"
        }
        
        break
    }
    "3" {
        Write-Output "Powershell 3 configuration" 
        Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 2048 
        Set-Item WSMan:\localhost\Shell\MaxShellsPerUser 100 
        Set-Item WSMan:\localhost\Shell\MaxConcurrentUsers 30 
        Set-Item WSMan:\localhost\Shell\MaxProcessesPerShell 100 
        Set-Item WSMan:\localhost\Shell\MaxConcurrentOperationsPerUser 2048 
        Set-Item WSMan:\localhost\Plugin\Microsoft.PowerShell\Quotas\MaxMemoryPerShellMB 2048 
        Set-Item WSMan:\localhost\Plugin\Microsoft.PowerShell\Quotas\MaxShellsPerUser 100 
        Set-Item WSMan:\localhost\Plugin\Microsoft.PowerShell\Quotas\MaxConcurrentUsers 30 
        Set-Item WSMan:\localhost\Plugin\Microsoft.PowerShell\Quotas\MaxProcessesPerShell 100 
        Set-Item WSMan:\localhost\Plugin\Microsoft.PowerShell\Quotas\MaxConcurrentOperationsPerUser 2048 

        Restart-Service winrm
        break
    }
    default {
        Write-Output "Powershell Default Config" 
        break
    }

}

# 
Write-Output "Opening WinRM to the outside world" 
winrm set winrm/config/client/auth '@{Basic="true"}' 
winrm set winrm/config/service/auth '@{Basic="true"}' 
winrm set winrm/config/service '@{AllowUnencrypted="true"}' 

Write-Output "Script Finished" 
