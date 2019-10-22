# Compatibility script to install Cygwin 2.4.0
#
# Original Powershell comments put here for reference
#
# Install and configure Cygwin.
# This is being done in a separate script to the windows packages deliberately, as the windows
# packages are common to both Cygwin and and bitvise machines.
#
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
#    --packages alternatives,autoconf,autoconf2.1,autoconf2.5,base-cygwin,base-files,bash,binutils,...... \
#    --local-package-dir C:\\Packer\\Downloads\\cygwin\\packages

class windows_template::ssh::cygwin_240()
{

  # Lift list of packages from seperate file for clarity.
  include windows_template::ssh::cygwin_pkgs

  # Arch Dependant and other variable setup

  if ($::architecture == 'x64')
  {
    $cygwin_dir = 'C:\cygwin64'
    $cygend_prefix = 'C:/cygwin64'
    $setup_arch = 'x86_64'
  } else {
    $cygwin_dir = 'C:\cygwin'
    $cygend_prefix = 'C:/cygwin'
    $setup_arch = 'x86'
  }

  $cygwin_downloads = "${::packer_downloads}\\Cygwin"
  $cygwin_download_url = 'https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/cygwin'

  $cygwin_packages = "packages-${setup_arch}.zip"
  $cgywin_installer = "setup-${setup_arch}.exe"

  # Prepare Cygwin install script
  $pkg_list_arg = join($windows_template::ssh::cygwin_pkgs::cygwin_pkg_list, ',')
  $cygwin_exec = @("CYGWIN_INS"/$)
      \$CygwinArguments = "--quiet-mode " + `
                        "--packages ${pkg_list_arg} " + `
                        "--no-verify --local-install " + `
                        "--root ${cygwin_dir} " + `
                        "--local-package-dir ${cygwin_downloads}\\packages"
      Write-Output "Arguments are: \$CygwinArguments"
      Start-Process -Wait "${cygwin_downloads}\\${cgywin_installer}" -PassThru -NoNewWindow -ArgumentList "\$CygwinArguments"
      Write-Output \$null > C:\\Packer\\Logs\\Cygwin.Installed
      | CYGWIN_INS

  # Actual Resources (chained in order) to install Cygwin.
  windows_env { 'CYGWINDIR-ENV':
    ensure   => present,
    variable => 'CYGWINDIR',
    value    => $cygwin_dir,
  }
  -> windows_env { 'GIT_EDITOR ENV':
    ensure   => present,
    variable => 'GIT_EDITOR',
    value    => "${cygend_prefix}/bin/vi.exe",
  }
  -> archive { "${cygwin_downloads}\\${cygwin_packages}" :
    ensure       => present,
    source       => "${cygwin_download_url}/${cygwin_packages}",
    extract_path => $cygwin_downloads,
    extract      => true,
    cleanup      => false,
  }
  -> download_file { $cgywin_installer :
    url                   => "${cygwin_download_url}/${cgywin_installer}",
    destination_directory => $cygwin_downloads
  }
  # exec to run the cygwin installer
  -> exec { 'Install Cygwin':
      command   => $cygwin_exec,
      unless    => 'if (-Not (Test-Path C:\Packer\Logs\Cygwin.Installed) ) {Exit 1}',
      provider  => powershell,
      logoutput => true,
  }
  #
  # File copies to complete the installation.
  # Copy setup program to C:\Windows\system32 to deal with beaker issue (RE-7855)
  -> file { "${::windir}\\system32\\${cgywin_installer}":
      ensure => file,
      source => "${cygwin_downloads}/${cgywin_installer}",
  }
  # Update fstab to set NOACL across the board (IMAGES-825)
  -> file { "${cygwin_dir}\\etc\\fstab":
      ensure => file,
      source => "${::packer_config}\\fstab",
  }
}
