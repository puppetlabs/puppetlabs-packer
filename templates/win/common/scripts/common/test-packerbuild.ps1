# Uses Pester to execute validation tests on the packer build
# This is a multi-use script for several stages in the process.

param (
  [string]$TestPhase
 )

$ErrorActionPreference = 'Stop'

. C:\Packer\Scripts\windows-env.ps1

# Download Pester if needed.
# We do an explicit download and import module here so that we can support from PS2 -> Current without
# needing to install a package manager. We also DO NOT want to leave Pester permanently installed
# on the image, so its imported as needed in this script only.

# Important Pre-requisite right across the packer  including Windows Update adn the test framework.
Install-7ZipPackage

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

# Print out Log for the phase with a prologue if a log file exists
if (Test-Path "C:\Packer\Logs\$TestPhase.log") {
    Write-Output "Printing Log for $TestPhase"

    Write-Output "==========  Log for: $TestPhase START ========"
    Get-Content -Path "C:\Packer\Logs\$TestPhase.log" | ForEach-Object {Write-Output $_}
    Write-Output "========== Log: $TestPhase END ========"
    
    Start-Sleep -Seconds 10
}

# Now for the Test Proper - assuming they exist of course

$PesterResults = Invoke-Pester -Script "$PackerAcceptance\$TestPhase\" -PassThru

if ($PesterResults.FailedCount -gt 0) {
    Write-Output "Failures detected - aborting build"
    Exit 1
}
