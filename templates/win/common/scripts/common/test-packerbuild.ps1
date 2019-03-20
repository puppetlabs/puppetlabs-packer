<#
  .SYNOPSIS
	Script to test the packer builds
  .DESCRIPTION
    Uses Pester to execute validation tests on the packer build
    This is a multi-use script for several stages in the process.
  .PARAMETER TestPhase
    The TestPhase parameter executes the tests in the directory
    c:\Packer\Acceptance\<TestPhase>
    It also prints out the logfile C:\Packer\Logs\<TestPhase>.log 
    if present
#>

param (
  # See validation for $TestPhase below (ensures that we have directory under 
  # Acceptance matching the TestPhase name)
  [string]$TestPhase 
)

$ErrorActionPreference = 'Stop'

. C:\Packer\Scripts\windows-env.ps1

Write-Output "========== Starting Packer Test Phase: $TestPhase ========"

# Adding Validation here to ensure we have a test phase available.
if (-not (Test-Path "$PackerAcceptance\$TestPhase\")) {
    Write-Error "Test Packages for $TestPhase not available aborting"
    Exit 1
}

# Download Pester if needed.
# We do an explicit download and import module here unless we are Win-10/2016.
# This is so that we can support from PS2 -> Current without needing to install a package manager. 
# We also DO NOT want to leave Pester permanently installed on the image, so its imported 
# as needed in this script only.
if ($WindowsVersion -Like $WindowsServer2016) {
    Touch-File "$PackerLogs\Pester.installed"
}

# And Download Pester (unless its Windows 10/2016 where pester is already installed)
if (-not (Test-Path "$PackerLogs\Pester.installed")) {
    # Important Pre-requisite right across the packer including Windows Update and the test framework.
    Install-7ZipPackage
    Write-Output "Downloading Pester "
    $PesterZip = "Pester-4.4.2.zip"
    Download-File "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/pester/$PesterZip" "$Env:TEMP\$PesterZip"
    $zproc = Start-Process "$7zip" @SprocParms -ArgumentList "x $Env:TEMP\$PesterZip -y -o$PackerPsModules"
    $zproc.WaitForExit()

    Touch-File "$PackerLogs\Pester.installed"
    Write-Output "Pester Installed"
}

if ($WindowsVersion -NotLike $WindowsServer2016) {
    Write-Output "Importing Pester Module"
    Import-Module "$PackerPsModules\Pester-4.4.2\Pester.psd1"
}

# Print out Log for the phase with a prologue if a log file exists
if (Test-Path "C:\Packer\Logs\$TestPhase.log") {
    Write-Output "========== Printing Log for $TestPhase ========"

    Write-Output "==========  Log for: $TestPhase START ========"
    Get-Content -Path "C:\Packer\Logs\$TestPhase.log"
    Write-Output "========== Log: $TestPhase END ========"
    
    Start-Sleep -Seconds 10
}

# Now for the Test Proper - assuming they exist of course
# With a very rich hack for Win-2008 to suppress Notepad/Chrome errors.
# Could add some additional tagging but the extra level of testing for this simply isn't worth it to
# support an OS that's EOL at end of year.

If ( $WindowsServerCore -or ($WindowsVersion -Like $WindowsServer2008)) {
    $PesterResults = Invoke-Pester -Script "$PackerAcceptance\$TestPhase\" -PassThru -ExcludeTag 'DesktopOnly'
} else {
    $PesterResults = Invoke-Pester -Script "$PackerAcceptance\$TestPhase\" -PassThru -ExcludeTag 'CoreOnly'
}

Write-Output "========== Completed Packer Test Phase: $TestPhase ========"
if ($PesterResults.FailedCount -gt 0) {
    Write-Output "Failures detected - aborting build"
    Exit 1
} 
