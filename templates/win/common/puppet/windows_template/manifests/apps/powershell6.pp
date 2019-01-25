# Installs and configures Powershell 6 (core)

class windows_template::apps::powershell6()
{
  $ps6coredownloadurl = 'https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/powershell6-core'

  # Select package name/install title depending on archictecture
  if ($::architecture == 'x86') {
    $ps6coreinstaller = 'PowerShell-6.1.1-win-x86.msi'
    $ps6corearchtype = 'x86'
  } else {
    $ps6coreinstaller = 'PowerShell-6.1.1-win-x64.msi'
    $ps6corearchtype = 'x64'
  }

  download_file { $ps6coreinstaller :
    url                   => "${ps6coredownloadurl}/${ps6coreinstaller}",
    destination_directory => $::packer_downloads
  }
  -> package { "PowerShell 6-${ps6corearchtype}":
    ensure          => installed,
    source          => "${::packer_downloads}\\${ps6coreinstaller}",
    install_options => ['/q']
  }
}
