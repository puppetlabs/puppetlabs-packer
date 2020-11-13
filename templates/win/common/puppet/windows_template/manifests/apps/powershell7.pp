# Installs and configures Powershell 6 (core)

class windows_template::apps::powershell7()
{
  $ps7coredownloadurl = 'https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/powershell7'

  # Select package name/install title depending on archictecture
  if ($::architecture == 'x86') {
    $ps7coreinstaller = 'PowerShell-7.1.0-win-x86.msi'
    $ps7corearchtype = 'x86'
  } else {
    $ps7coreinstaller = 'PowerShell-7.1.0-win-x64.msi'
    $ps7corearchtype = 'x64'
  }

  download_file { $ps7coreinstaller :
    url                   => "${ps7coredownloadurl}/${ps7coreinstaller}",
    destination_directory => $::packer_downloads
  }
  -> package { "PowerShell 7-${ps7corearchtype}":
    ensure          => installed,
    source          => "${::packer_downloads}\\${ps7coreinstaller}",
    install_options => ['/q']
  }
}
