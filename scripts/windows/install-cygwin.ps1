# Install and configure Cygwin.
# This is being done in a separate script to the windows packages deliberately, as the windows
# packages are common to both Cygwin and and bitvise machines.
#

$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

# Work out what CYGDIR is and set it as a Windows Environment Variable
Write-Host "Setting CYGWINDIR"
if ($ARCH -eq 'x86') {
  $CygWinDir = "C:\cygwin"
} else {
  $CygWinDir = "C:\cygwin64"
}
$RegPath = 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
Set-ItemProperty -Path $RegPath -Name CYGWINDIR -Value $CygWinDir
Set-ItemProperty -Path $RegPath -Name CYGWINDOWNLOADS -Value $CygwinDownloads

# Read list of packages to be installed.
# This is a plain-text list of packages, where the first word on each line must be a single package name.
# The list is derived from "cygwin -c" on a Windows-2012 pooler VM wtih the initial lines removed.
#
$CygWinPackageList = ""
$content = Get-Content A:\cygwin-packages
foreach ($line in $content)
{
  $splitUp = $line -split "\s+"
  if ($CygWinPackageList.length -gt 1 ) {
    $CygWinPackageList = $CygWinPackageList + "," + $splitUp[0]
  } else {
    $CygWinPackageList = $splitUp[0]
  }
}

Write-Host "Package list is: $CygWinPackageList"
$CygWinSetup = "$CygwinDownloads\setup-$ARCH.exe"

# Download cygwin setup.exe and packages from local repo and unzip
Download-File "http://buildsources.delivery.puppetlabs.net/windows/cygwin/setup-$ARCH.exe" $CygWinSetup
Download-File "http://buildsources.delivery.puppetlabs.net/windows/cygwin/packages-$ARCH.zip" "$CygwinDownloads\packages_$ARCH.zip"

# Copy setup program to C:\Windows\system32 to deal with beaker issue (RE-7855)
Copy-Item -Path "C:\Packer\Downloads\Cygwin\setup-$ARCH.exe" -Destination "$ENV:WINDIR\system32\setup-$ARCH.exe"

# Setup Password for later use
if ($ENV:QA_ROOT_PASSWD.length -le 0 ) {throw "QA_ROOT_PASSWD is not defined"}
$ENV:QA_ROOT_PASSWD | Out-File "$CygwinDownloads\qapasswd"

$ostring = "-o" + $CygwinDownloads
& $7zip x "$CygwinDownloads\packages_$ARCH.zip" -y $ostring

# Install Cygwin from the download location.
& $CygWinSetup --quiet-mode `
               --packages $CygWinPackageList `
               --no-verify `
               --local-install `
               --root $CygWinDir `
               --local-package-dir $CygwinDownloads\packages


# Sleep to let console log catch up (and get captured by packer)
Start-Sleep -Seconds 20

exit 0
# end
