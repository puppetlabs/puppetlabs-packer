# Class to install the Linux/WSL distribution of Linux and install it.
# So as to replace Cygwin/ssh with this instead.
#
# This is based on the instructions at:
# https://docs.microsoft.com/en-us/windows/wsl/install-manual
# https://docs.microsoft.com/en-us/windows/wsl/install-on-server
# https://docs.microsoft.com/en-us/windows/wsl/initialize-distro
#
# The Sysprep process means that the actual Ubuntu install needs to be done post-clone.
# just unpacking the distribution for preparation here.
# See https://github.com/Microsoft/WSL/issues/1636
#
class windows_template::ssh::wsl_ssh ()
{

  $ubuntu_appx_file = 'CanonicalGroupLimited.Ubuntu18.04onWindows_1804.2018.817.0_x64__79rhkp1fndgsc.Appx'
  $artifactory_url = 'https://artifactory.delivery.puppetlabs.net/artifactory/generic__iso/iso/windows'

  # WSL Needs to be enabled first and will require a reboot if its not already enabled.
  windowsfeature { 'Microsoft-Windows-Subsystem-Linux':
    ensure  => present,
  }
  reboot {'after_WSL_Feature_Enable':
    when      => pending,
    subscribe => Windowsfeature['Microsoft-Windows-Subsystem-Linux'],
  }

  # Fetch and extract the Ubuntu Distribution
  file { $::wsldir:
    ensure => 'directory',
  }
  -> archive { "${::packer_downloads}\\${ubuntu_appx_file}" :
      ensure       => present,
      source       => "${artifactory_url}/${ubuntu_appx_file}",
      extract_path => $::wsldir,
      extract      => true,
      cleanup      => false,
      require      => Windowsfeature['Microsoft-Windows-Subsystem-Linux'],
  }
}
