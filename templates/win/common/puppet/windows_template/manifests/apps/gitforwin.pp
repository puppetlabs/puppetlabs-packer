# Installs Git for Windows and configures start page.
class windows_template::apps::gitforwin()
{
  $gitforwindownloadurl = 'https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/gitforwin'

  # Select package name/install title depending on archictecture
  if ($::architecture == 'x86') {
    $gitforwininstaller = 'Git-2.29.2.2-32-bit.exe'
  } else {
    $gitforwininstaller = 'Git-2.29.2.2-64-bit.exe'
  }

  download_file { $gitforwininstaller :
    url                   => "${gitforwindownloadurl}/${gitforwininstaller}",
    destination_directory => $::packer_downloads
  }
  -> package { 'Git version 2.29.2.2': # This version has strange string.
    ensure          => installed,
    source          => "${::packer_downloads}\\${gitforwininstaller}",
    install_options => ['/VERYSILENT', "/LOADINF=${::packer_config}\\gitforwin.inf"]
  }
}
