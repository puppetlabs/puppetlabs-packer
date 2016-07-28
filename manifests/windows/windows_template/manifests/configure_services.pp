class windows_template::configure_services()
{
    # TODO Disable Windows Search Service if it exists

    # Configure WinRM service
    service { 'WinRM':
      ensure => 'running',
      enable => true,
    }

    # Disable Windows Update service
    service { 'wuauserv':
      ensure => 'stopped',
      enable => false,
    }
}
