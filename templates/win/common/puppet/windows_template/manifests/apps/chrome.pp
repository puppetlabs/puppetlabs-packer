# Installs Chrome and configures start page.
class windows_template::apps::chrome()
{
  $chromedownloadurl = 'https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/googlechrome'

  # Select package name/install title depending on archictecture
  if ($::architecture == 'x86') {
    $chromeinstaller = 'GoogleChromeStandaloneEnterprise.84.0.4147.125.msi'
  } else {
    $chromeinstaller = 'GoogleChromeStandaloneEnterprise64.84.0.4147.125.msi'
  }

  download_file { $chromeinstaller :
    url                   => "${chromedownloadurl}/${chromeinstaller}",
    destination_directory => $::packer_downloads
  }
  -> package { 'Google Chrome':
    ensure          => installed,
    source          => "${::packer_downloads}\\${chromeinstaller}",
    install_options => ['/q']
  }

  # Following resources all depend on Google already being installed.
  file { "${::chrome_root}\\Application\\master_preferences":
    owner   => $::administrator_sid,
    group   => $::administrator_grp_sid,
    source  => "${::modules_path}\\windows_template\\files\\master_preferences",
    require => Package['Google Chrome'],
  }
  # Disable Google Update Services to prevent pending reboot requests (except win-2008)
  service { 'gupdate':
    ensure  => 'stopped',
    enable  => false,
    require => Package['Google Chrome'],
  }
  service { 'gupdatem':
    ensure  => 'stopped',
    enable  => false,
    require => Package['Google Chrome'],
  }
}
