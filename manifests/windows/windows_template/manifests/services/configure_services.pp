# Set the service states
#
class windows_template::services::configure_services()
{
    # TODO Disable Windows Search Service if it exists

    # Configure WinRM service
    service { 'WinRM':
      ensure => 'running',
      enable => true,
    }
    # Netbios and lmosts are handled in scripting as they
    # need to be sequenced carefully during the post-clone-first-boot

    # Disable Windows Update service
    service { 'wuauserv':
      ensure => 'stopped',
      enable => false,
    }

    # Following services are only considered in Non-Core installation.
    if ($::windows_install_option != 'Core')
    {
      # Disable Audiosrv (Audio) service
      service { 'Audiosrv':
        ensure => 'stopped',
        enable => false,
      }
    }
}
