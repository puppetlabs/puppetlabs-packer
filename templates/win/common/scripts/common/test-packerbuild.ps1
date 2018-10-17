# Uses Pester to execute validation tests on the packer build
# This is a multi-use script for several stages in the process.

param (
  [string]$TestPhase,
  [switch]$DoPrintLog
 )

$ErrorActionPreference = 'Stop'

. C:\Packer\Scripts\windows-env.ps1

# Download Pester if needed.
# We do an explicit download and import module here so that we can support from PS2 -> Current without
# needing to install a package manager. We also DO NOT want to leave Pester permanently installed
# on the image, so its imported as needed in this script only.

# Important Pre-requisite right across the packer  including Windows Update adn the test framework.
if (-not (Test-Path "$PackerLogs\7zip.installed")) {
    # Download and install 7za now as its needed here and is useful going forward.
    $SevenZipInstaller = "7z1604-$ARCH.exe"
    Write-Output "Installing 7zip $SevenZipInstaller"
    Download-File "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/7zip/$SevenZipInstaller"  "$Env:TEMP\$SevenZipInstaller"
    Start-Process -Wait "$Env:TEMP\$SevenZipInstaller" @SprocParms -ArgumentList "/S"
    Touch-File "$PackerLogs\7zip.installed"
    Write-Output "7zip Installed"
}

# And Download Pester.
if (-not (Test-Path "$PackerLogs\Pester.installed")) {
    Write-Output "Downloading Pester "
    $PesterZip = "Pester-4.4.2.zip"
    Download-File "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/pester/$PesterZip" "$Env:TEMP\$PesterZip"
    $zproc = Start-Process "$7zip" @SprocParms -ArgumentList "x $Env:TEMP\$PesterZip -y -o$PackerPsModules"
    $zproc.WaitForExit()

    Touch-File "$PackerLogs\Pester.installed"
    Write-Output "Pester Installed"
}

Write-Output "Importing Pester Module"
Import-Module "$PackerPsModules\Pester-4.4.2\Pester.psd1"

# Print out Log for the phase with a prologue

if ($DoPrintLog) {
    Write-Output "Printing Log for $TestPhase"

    Write-Output "==========  Log for: $TestPhase START ========"
    Get-Content -Path "C:\Packer\Logs\$TestPhase.log" | ForEach-Object {Write-Output $_}
    Write-Output "========== Log: $TestPhase END ========"
    
    Start-Sleep -Seconds 10
}

# Now for the Test Proper.




