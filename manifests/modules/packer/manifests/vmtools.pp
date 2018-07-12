class packer::vmtools inherits packer::vmtools::params {

  # At some point it's going to become more worthwhile to flip this so
  # installing open-vm-tools is the default.
  if ( ($::osfamily == 'debian' and $::operatingsystemmajrelease in ['7', '8', '9', '16.04', '18.04']) or
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

    mount { '/tmp/vmtools':
      ensure  => mounted,
      device  => "${root_home}/${tools_iso}",
      fstype  => 'iso9660',
      options => 'ro,loop',
      require => File[ '/tmp/vmtools' ],
    }

    exec { 'install vmtools':
      command => $install_cmd,
      path    => [ '/bin', '/usr/bin', ],
      require => Mount[ '/tmp/vmtools' ],
    }

    exec { 'remove /tmp/vmtools':
      command => 'umount /tmp/vmtools ; rmdir /tmp/vmtools',
      path    => [ '/bin', '/usr/bin', ],
      onlyif  => 'test -d /tmp/vmtools',
      require => Exec[ 'install vmtools' ],
    }

    file { "${root_home}/${tools_iso}":
      ensure  => absent,
      require => Exec[ 'remove /tmp/vmtools' ],
    }

    file_line { "remove /etc/fstab /tmp/vmtools":
      path    => '/etc/fstab',
      line    => '#/tmp/vmtools removed',
      match   => '/tmp/vmtools',
      require => Exec[ 'remove /tmp/vmtools' ],
    }
  }
}
