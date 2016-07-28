class windows_template::disable_services()
{
    # TODO Disable Windows Search Service if it exists


    # Disable Windows Update service
    service { 'wuauserv':
      ensure => 'stopped',
      enable => false,
    }
}
