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

$ostring = "-o" + $CygwinDownloads
& $7zip x "$CygwinDownloads\packages_$ARCH.zip" -y $ostring

# Install Cygwin from the download location.
& $CygWinSetup --quiet-mode `
               --packages $CygWinPackageList `
               --no-verify `
               --local-install `
               --root $CygWinDir `
               --local-package-dir $CygwinDownloads\packages


exit 0
# end

# Any code/comments are are for TODO actions.

# Actual SSH configuration is done on the post-cloned machine.

# Possibly execute these on the post-clone script.

# SSH Configuration
& C:\cygwin64\bin\sh.exe  --login -c 'ssh-host-config -y --pwd hello'
& C:\cygwin64\bin\sh.exe  --login -c 'rm -rf /home/Administrator/.ssh/id_rsa'
& C:\cygwin64\bin\sh.exe  --login -c 'ssh-keygen -t rsa -N \"\" -f /home/Administrator/.ssh/id_rsa'
& C:\cygwin64\bin\sh.exe  --login -c 'cygrunsrv -S sshd'

# Set sshd server to manual

# Create/open the file "C:\%CYGWIN_DIR%\home\Administrator\.ssh\authorized_keys"
# Add your desired public keys and save the file.

# Packages to Install
