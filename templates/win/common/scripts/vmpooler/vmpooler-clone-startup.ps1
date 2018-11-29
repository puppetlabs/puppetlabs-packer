# VMPooler Startup Script
# This is now run as a scheduled task at boot.

. C:\Packer\Scripts\windows-env.ps1

$rundate = date
write-output "Script: vmpooler-clone-startup.ps1 Starting at: $rundate"

$ErrorActionPreference = "Stop"

# Run vmstoolsd
Write-Output "Starting vmstoolsd"
$VMToolsd = "$($env:ProgramFiles)\VMware\VMware Tools\vmtoolsd.exe"
& $VMToolsd -n vmusr

# Run the BGInfo Task at startup, as scheduler will wait 5 mins.
If ( -not $WindowsServerCore ) {
    schtasks /run /tn UpdateBGInfo
}

# CYGWINDIR is set in the environment when Cygwin is installed
$CygwinDir = "$ENV:CYGWINDIR"
$CygwinMkpasswd = "$CygwinDir\bin\mkpasswd.exe -l"
$CygwinMkgroup = "$CygwinDir\bin\mkgroup.exe -l"
$CygwinPasswdFile = "$CygwinDir\etc\passwd"
$CygwinGroupFile = "$CygwinDir\etc\group"

#Snooze for a bit
sleep -s 10

#--- SCRIPT ---#
Write-Output "Updating the Cygwin passwd file!"

#Update the passwd file.
Invoke-Expression $CygwinMkpasswd | Out-File $CygwinPasswdFile -Force -Encoding "ASCII"
Invoke-Expression $CygwinMkgroup | Out-File $CygwinGroupFile -Force -Encoding "ASCII"

if (-not (Test-Path "$PackerLogs\WinRMHTTPS.installed"))
{
    # First wait until WinRm Service is available - allowing a very generous startup time
    # Seems to be needed as 30 seconds timed out on some machines.
    Write-Output "Checking/Waiting for running WinRm"
    $WinRmService = Get-Service -Name WinRM
    $WinRmService.WaitForStatus("Running",'00:02:00')
    # The further short sleep here is purely precautionary to ensure that WinRM is ready for requests.
    # Given that the last test run was sucessful, going to leave this here.
    Start-Sleep -Seconds 2

    # Winrm over HTTPS Configuration - using our DNS name for CN
    Write-Output "Configurating WinRM over HTTPS"
    $DNSHostname = "$(hostname).delivery.puppetlabs.net"

    # Windows 7/2008/2008R2 as always need compatibility code.
    # Using instructions from: https://blog.jayway.com/2011/11/21/winrm-w-self-signed-certificate-in-4-steps/
    # A copy of makecert was obtained from: https://stackoverflow.com/questions/5510063/makecert-exe-missing-in-windows-7-how-to-get-it-and-use-it
    # Using this method across all platforms to reduce complexity/branching.
    Write-Output "Generating Certification (makecert)"
    & $PackerScripts/makecert -sk "$DNSHostname" -ss My -sr LocalMachine -r -n "CN=$DNSHostname" -a sha1 -eku "1.3.6.1.5.5.7.3.1"
    $NewCert = ls cert:LocalMachine\my

    # Enable HTTPS
    Write-Output "Configuring WinRm for HTTPS"
    New-WSManInstance -ResourceURI winrm/config/Listener -SelectorSet @{Address='*';Transport='HTTPS'} -ValueSet @{Hostname=$DNSHostname;CertificateThumbprint=$NewCert.Thumbprint}

    Touch-File "$PackerLogs\WinRMHTTPS.installed"
}

Write-Output "Bye"
