class windows_template::configure_services()
{
    # TODO Disable Windows Search Service if it exists

    # Configure WinRM service
    service { 'WinRM':
      ensure => 'running',
      enable => true,
    }

    # Disable Netbios and relates services
    service { 'lmhosts':
      ensure => 'stopped',
      enable => false,
    }
    service { 'netbt':
      ensure => 'stopped',
      enable => false,
    }
    # Disable Windows Update service
    service { 'wuauserv':
      ensure => 'stopped',
      enable => false,
    }
}
