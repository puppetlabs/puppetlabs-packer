# Set the service states
#
class windows_template::services::configure_services()
{
    # TODO Disable Windows Search Service if it exists

    # Used to configure WinRM Service, but this had to be removed with the
    # revised puppet configure loop within a reboot cycle - enabling WinRM
    # here has the effect of completely breaking the configure cycle.

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
