class packer::vmtools inherits packer::vmtools::params {

  # At some point it's going to become more worthwhile to flip this so
  # installing open-vm-tools is the default.
  if ( ($::osfamily == 'debian' and $::operatingsystemmajrelease in ['7', '8', '9', '16.04', '18.04', '18.10']) or
        ($::osfamily == 'redhat' and $::operatingsystemmajrelease in ['7', '25', '26', '27', '28']) or
        ($::osfamily == 'suse' and $::operatingsystemmajrelease in ['15'])
    ) {
      package { 'open-vm-tools':
        ensure => installed,
      }
      file { '/mnt/hgfs':
        ensure => directory,
      }
  } else {
    # Install vmtools from the ISO
    if ( $required_packages != undef ) {
      package { $required_packages:
        ensure => installed,
        before => File[ '/tmp/vmtools' ],
      }
    }

    file { '/tmp/vmtools':
      ensure => directory,
    }

    if $::osfamily == 'Solaris' {
      mount { '/tmp/vmtools':
        ensure      => mounted,
        device      => "${root_home}/${tools_iso}",
        fstype      => 'hsfs',
        remounts    => false,
        blockdevice => '/dev/rdsk/c0d0s0',
        atboot      => true,
        options     => 'ro,loop',
        require     => File[ '/tmp/vmtools' ],
      }
    } else {
      mount { '/tmp/vmtools':
        ensure  => mounted,
        device  => "${root_home}/${tools_iso}",
        fstype  => 'iso9660',
        options => 'ro,loop',
        require => File[ '/tmp/vmtools' ],
      }
    }

    exec { 'install vmtools':
      command => $install_cmd,
      path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ],
      cwd     => '/tmp/',
      require => Mount[ '/tmp/vmtools' ],
    }

    if $::osfamily == 'Solaris' {
      # this is required because the vmware-tools installation fails with 0 exit code
      # the next step tries to validate that the service is running.
      service { 'vmware-tools':
        ensure   => running,
        require  => Exec[ 'install vmtools' ],
        start    => '/etc/init.d/vmware-tools start && /etc/init.d/vmware-tools status',
        stop     => '/etc/init.d/vmware-tools stop',
        status   => '/etc/init.d/vmware-tools status',
        provider => base
      }
    }

    exec { 'remove /tmp/vmtools':
      command => 'umount /tmp/vmtools ; rmdir /tmp/vmtools',
      path    => [ '/sbin', '/usr/sbin', '/bin', '/usr/bin' ],
      onlyif  => 'test -d /tmp/vmtools',
      require => Exec[ 'install vmtools' ],
    }

    file { "${root_home}/${tools_iso}":
      ensure  => absent,
      require => Exec[ 'remove /tmp/vmtools' ],
    }

    if $::osfamily == 'Solaris' {
      $fstab_path = '/etc/vfstab'
    } else {
      $fstab_path = '/etc/fstab'
    }

    file_line { 'remove fstab /tmp/vmtools':
      path    => $fstab_path,
      line    => '#/tmp/vmtools removed',
      match   => '/tmp/vmtools',
      require => Exec[ 'remove /tmp/vmtools' ],
    }
  }
}
