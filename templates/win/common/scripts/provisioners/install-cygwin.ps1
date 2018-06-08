Write-Output "Cygwin Installation Script"
# Install and configure Cygwin.
# This is being done in a separate script to the windows packages deliberately, as the windows
# packages are common to both Cygwin and and bitvise machines.
#
# Cygwin now installs directly from the Cygwin site - this documenation is retained for reference only.
# NOTE  Cygwin Packages were grabbed from Cygwin timemachine hosted on Fruitbat:
#         http://www.fruitbat.org/Cygwin/timemachine.html#cygwinmirror
# Index of releases at: ftp://www.fruitbat.org/pub/cygwin/circa/index.html
# 32 bit release used (2.4.0): ftp://www.fruitbat.org/pub/cygwin/circa/2016/01/16/111028
# 64 bit release used (2.4.0): ftp://www.fruitbat.org/pub/cygwin/circa/64bit/2016/01/16/041034

# Sample command to grab 32 bit packages:
# /cygdrive/c/cygwin_packages/setup-x86 \
#    -s ftp://www.fruitbat.org/pub/cygwin/circa/2016/01/16/111028 \
#    --download \
#    --only-site \
#    --no-verify \
#    --root C:\\cygwin64 \
#    --quiet-mode \
#    --packages alternatives,autoconf,autoconf2.1,autoconf2.5,base-cygwin,base-files,bash,binutils,bzip2,ca-certificates,coreutils,crypt,csih,curl,cygrunsrv,cygutils,cygwin,cygwin-devel,dash,diffutils,editrights,file,findutils,gawk,getent,git,grep,groff,gzip,hostname,info,ipc-utils,less,libargp,libasn1_8,libattr1,libblkid1,libbz2_1,libcom_err2,libcrypt0,libcurl4,libdb5.3,libedit0,libexpat1,libffi6,libfontconfig1,libfreetype6,libgcc1,libgdbm4,libgmp10,libgssapi3,libgssapi_krb5_2,libguile17,libheimbase1,libheimntlm0,libhx509_5,libiconv,libiconv2,libidn11,libintl8,libk5crypto3,libkafs0,libkrb5_26,libkrb5_3,libkrb5support0,libltdl7,liblzma5,libmetalink3,libmpfr4,libncursesw10,libopenldap2_4_2,libopenssl100,libp11-kit0,libpcre1,libpipeline1,libpng16,libpopt0,libreadline7,libroken18,libsasl2_3,libsigsegv2,libsmartcols1,libsqlite3_0,libssh2_1,libssp0,libstdc++6,libtasn1_6,libuuid-devel,libuuid1,libwind0,libwrap0,libX11_6,libXau6,libxcb1,libXdmcp6,libXext6,libXft2,libXrender1,libXss1,login,lynx,m4,make,makedepend,man,man-db,mintty,nano,openssh,openssl,p11-kit,p11-kit-trust,patch,patchutils,perl,perl-Carp,perl-Error,perl-Pod-Simple,perl_autorebase,perl_base,popt,python,python-tkinter,rebase,rsync,run,sed,tar,tcl,tcl-tix,tcl-tk,terminfo,texinfo,tzcode,util-linux,vim-minimal,which,xz,zlib0 \
#    --local-package-dir C:\\Packer\\Downloads\\cygwin\\packages

$ErrorActionPreference = 'Stop'
Write-Output "Loading Windows Environment"
. C:\Packer\Scripts\windows-env.ps1

# Work out what CYGDIR is and set it as a Windows Environment Variable
# Note - need seperate Prefix var for environment variables due to cygwin/git-for-win idiosyncrasies
Write-Output "Setting CYGWINDIR"
if ($ARCH -eq 'x86') {
  $CygWinDir = "C:\cygwin"
  $CygEnvPrefix = "C:/cygwin"
} else {
  $CygWinDir = "C:\cygwin64"
  $CygEnvPrefix = "C:/cygwin64"
}
$RegPath = 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
Set-ItemProperty -Path $RegPath -Name CYGWINDIR -Value $CygWinDir
Set-ItemProperty -Path $RegPath -Name CYGWINDOWNLOADS -Value $CygwinDownloads
# Fix for IMAGES-855 - Defining NM as env var resolves the libool "syntax error near unexpected token `|`" eval error
Set-ItemProperty -Path $RegPath -Name NM -Value "/usr/bin/nm"

# Read list of packages to be installed.
# This is a plain-text list of packages, where the first word on each line must be a single package name.
# The list is derived from "cygwin -c" on a Windows-2012 pooler VM wtih the initial lines removed.
#
$CygWinPackageList = ""
$content = Get-Content $PackerConfig\cygwin-packages
foreach ($line in $content)
{
  $splitUp = $line -split "\s+"
  if ($CygWinPackageList.length -gt 1 ) {
    $CygWinPackageList = $CygWinPackageList + "," + $splitUp[0]
  } else {
    $CygWinPackageList = $splitUp[0]
  }
}
Write-Output "Package list is: $CygWinPackageList"

# Setup Password for later use
if ($ENV:QA_ROOT_PASSWD.length -le 0 ) {throw "QA_ROOT_PASSWD is not defined"}
$ENV:QA_ROOT_PASSWD | Out-File "$CygwinDownloads\qapasswd"

Write-Output "Downloading Cygwin Setup"
$CygWinSetup = "$CygwinDownloads\setup-$ARCH.exe"
Download-File "https://cygwin.com/setup-$ARCH.exe" $CygWinSetup
# Install Cygwin directly from the Cygwin site - so using latest version.
# Start-Process -wait needed to address Win-2008 where the setup appears to run async and script exits before install has completed
Write-Output "Installing Cygwin"
$CygwinArguments = "--site http://cygwin.mirror.constant.com " + `
                   "--quiet-mode " + `
                   "--packages $CygWinPackageList " + `
                   "--no-verify " + `
                   "--root $CygWinDir " + `
                   "--local-package-dir $CygwinDownloads\packages"
Start-Process -Wait "$CygWinSetup" -PassThru -NoNewWindow -ArgumentList "$CygwinArguments"

# Copy setup program to C:\Windows\system32 to deal with beaker issue (RE-7855)
Write-Output "Copying $CygWinSetup to $ENV:WINDIR\system32"
Copy-Item -Path "$CygWinSetup" -Destination "$ENV:WINDIR\system32\setup-$ARCH.exe"

# Set GIT Related env variables to ensure correct editor is used etc.
Write-Output "Set GIT Environment variables to use Cygwin utils"
$RegPath = 'Registry::HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
Set-ItemProperty -Path $RegPath -Name GIT_EDITOR -Value "$CygEnvPrefix/bin/vi.exe"

# Update fstab to set NOACL across the board (IMAGES-825)
Write-Output "Setting NOACL for all file creates"
Copy-Item -Path "$PackerConfig\fstab" "$CygWinDir\etc\fstab"

# Sleep to let console log catch up (and get captured by packer)
Start-Sleep -Seconds 20

exit 0
# end
