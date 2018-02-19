# GCE Host Startup Script.
# To make sure the correct parameters are set depending on the Powershell version for WMF 2.0/3.0
#

$GceStartupLog = "C:\Packer\Logs\gce-append-output.txt"

Write-Output "Script Starting" 2>&1 >> "$GceStartupLog"
Write-Output "Setting Execution Policy" 2>&1 >> "$GceStartupLog"

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force 2>&1 >> "$GceStartupLog"

winrm quickconfig -quiet 2>&1 >> "$GceStartupLog"

$PsVersionMajor = $PSVersionTable.PSVersion.Major
Write-Output "Powershell Version $PsVersionMajor" 2>&1 >> "$GceStartupLog"

switch ($PsVersionMajor) {

    "2" {
        Write-Output "Powershell 2 configuration" 2>&1 >> "$GceStartupLog"
        Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 2048 2>&1 >> "$GceStartupLog"
        Get-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB  2>&1 >> "$GceStartupLog"
        break
    }
    "3" {
        Write-Output "Powershell 3 configuration" 2>&1 >> "$GceStartupLog"
        Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 5000 2>&1 >> "$GceStartupLog"
        Set-Item WSMan:\localhost\Plugin\Microsoft.PowerShell\Quotas\MaxMemoryPerShellMB 5000 2>&1 >> "$GceStartupLog"
        Set-Item WSMan:\localhost\Shell\MaxShellsPerUser 100 2>&1 >> "$GceStartupLog"
        Set-Item WSMan:\localhost\Shell\MaxConcurrentUsers 30 2>&1 >> "$GceStartupLog"
        Set-Item WSMan:\localhost\Shell\MaxProcessesPerShell 100 2>&1 >> "$GceStartupLog"
        Set-Item WSMan:\localhost\Shell\MaxConcurrentOperationsPerUser 5000 2>&1 >> "$GceStartupLog"

        Restart-Service winrm
        break
    }
    default {
        Write-Output "Powershell Default Config" 2>&1 >> "$GceStartupLog"
        break
    }

}

Write-Output "Opening WinRM to the outside world" 2>&1 >> "$GceStartupLog"
winrm set winrm/config/client/auth '@{Basic="true"}' 2>&1 >> "$GceStartupLog"
winrm set winrm/config/service/auth '@{Basic="true"}' 2>&1 >> "$GceStartupLog"
winrm set winrm/config/service '@{AllowUnencrypted="true"}' 2>&1 >> "$GceStartupLog"

Write-Output "Script Finished" 2>&1 >> "$GceStartupLog"
