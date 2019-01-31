# Platform9 Configuration Script.
# Placeholder for Platform 9 scripts.

. C:\Packer\Scripts\windows-env.ps1

$rundate = date
write-output "Script: platform9-config.ps1 Starting at: $rundate"

Write-Output "Fetching Virtual IO Drivers for platform9"
$VirtIoDrivers = "virtio-win-0.1.141"
Download-File "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/platform9/$VirtIoDrivers.iso" "$Env:TEMP/$VirtIoDrivers.iso"
$zproc = Start-Process "$7zip" @SprocParms -ArgumentList "x $Env:TEMP/$VirtIoDrivers.iso -y -o$PackerDownloads\$VirtIoDrivers"
$zproc.WaitForExit()

# Install Drivers - need to install RedHat Cert as well to allow drivers to be trusted.
certutil -addstore "TrustedPublisher" "$PackerScripts\RedHat.cer"
$ArchDir = "amd64"
$ArchExt = "x64"
if ($ARCH -eq 'x86') {
    $ArchExt = "x64"
    $ArchDir = "x86"
}
 
$DriverDirectory = "$PackerDownloads\$VirtIoDrivers"
$DriversList = @("Balloon","NetKVM","qemupciserial","viorng","vioscsi","vioserial","viostor")
foreach ($DriverName in $DriversList) {
    $OsPrefix = ""
    switch -wildcard ($WindowsProductName) {
        # Ordering is important here with the wilcards, so that the R2 versions are picked
        # off first, otherwise fallthru to the next match.
        "Windows Server 2016*" { $OsPrefix = "2k16"; break}
        "Windows 7*" { $OsPrefix = "w7"; break}
        "Windows 8.1*" { $OsPrefix = "w8.1"; break}
        "Windows 10*" { $OsPrefix = "w10"; break}
        "Windows Server 2012 R2*" { $OsPrefix = "2k12R2"; break}
        "Windows Server 2012*" { $OsPrefix = "2k12"; break}
        "Windows Server 2008 R2*" { $OsPrefix = "2k8R2"; break}
        "Windows Server 2008*" { $OsPrefix = "2k8"; break}
        "Windows Server 2016*" { $OsPrefix = "2k16"; break}
        "Windows Server 2019*" { $OsPrefix = "2k16"; break}
        default { $OsPrefix = "2k16"; break}
    }
    Write-Output "Installing Drivers for $DriverName"
    # Locate Inf File in the directory and use that.
    pnputil /a "$DriverDirectory\$DriverName\$OsPrefix\$ArchDir\*.inf" /i

}

Write-Output "Installing QEMU Agent"
$zproc = Start-Process "msiexec" @SprocParms -ArgumentList "/i $DriverDirectory\guest-agent\qemu-ga-$ArchExt.msi"
$zproc.WaitForExit()

Write-Output "Installing Cloudbase Init"
# msiexec /i CloudbaseInitSetup_x64.msi /qn /l*v log.txt CLOUDBASEINITCONFFOLDER="C:\" LOGGINGSERIALPORTNAME="COM1" BINFOLDER="C:\bin" LOGFOLDER="C:\log" USERNAME="admin1" INJECTMETADATAPASSWORD="TRUE" USERGROUPS="Administrators" LOGGINGSERIALPORTNAME="COM2" LOCALSCRIPTSFOLDER="C:\localscripts"
$CloudbaseInstaller = "CloudbaseInitSetup_0_9_11_$ArchExt.msi"
Download-File "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/platform9/$CloudbaseInstaller" "$PackerDownloads\$CloudbaseInstaller"
$zproc = Start-Process "msiexec" @SprocParms -ArgumentList "/i $PackerDownloads\$CloudbaseInstaller /qn /l*v $PackerLogs\CloudbaseInstaller.log"
$zproc.WaitForExit()

Write-Output "Bye"
