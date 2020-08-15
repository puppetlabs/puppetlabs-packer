# Installs and configures NotePad Plus Plus
# with the updater (and its irritating prompt) disabled.

class windows_template::apps::notepadplusplus()
{
  $notepadppdownloadurl = 'https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/notepadplusplus'

  # Select package name/install title depending on archictecture
  if ($::architecture == 'x86') {
    $notepadppinstaller = 'npp.7.8.9.Installer.exe'
    $notepadpparchtype = '(32-bit x86)'
  } else {
    $notepadppinstaller = 'npp.7.8.9.Installer.x64.exe'
    $notepadpparchtype = '(64-bit x64)'
  }

  download_file { $notepadppinstaller :
    url                   => "${notepadppdownloadurl}/${notepadppinstaller}",
    destination_directory => $::packer_downloads
  }
  -> package { "Notepad++ ${notepadpparchtype}":
    ensure          => installed,
    source          => "${::packer_downloads}\\${notepadppinstaller}",
    # As per NPP 7.5, the /noUpdater option disables the updater installation.
    # https://notepad-plus-plus.org/download/v7.5.html
    install_options => ['/S','/noUpdater']
  }
}

