class windows_template::configure_services()
{
    # TODO Disable Windows Search Service if it exists

    # Configure WinRM service
    service { 'WinRM':
      ensure => 'running',
      enable => true,
    }
    # Disable Audiosrv (Audio) service
    service { 'Audiosrv':
      ensure => 'stopped',
      enable => false,
    }

    # Netbios and lmosts are handled in scripting as they
    # need to be sequenced carefully during the post-clone-first-boot

    # Disable Windows Update service
    service { 'wuauserv':
      ensure => 'stopped',
      enable => false,
    }

    # Disable Google Update Services to prevent pending reboot requests (except win-2008)
    if ($::operatingsystemrelease != '2008')
    {
      service { 'gupdate':
        ensure => 'stopped',
        enable => false,
      }
      service { 'gupdatem':
        ensure => 'stopped',
        enable => false,
      }
    }
}
