class packer::vmtools inherits packer::vmtools::params {

  case $::osfamily {
    debian: {
      # Debian 9.0 alpha release returns 'stretch/sid' for operatingsystemrelease:
      if $::operatingsystemrelease in ['stretch/sid', '16.04', '16.10', '8.0'] {
        package { 'open-vm-tools':
          ensure => installed,
        }
        file { '/mnt/hgfs':
        ensure => directory,
        }
      }
    }

    redhat: {
      if $::operatingsystemmajrelease in ['25', '7'] {
        package { 'open-vm-tools':
          ensure => installed,
        }
        file { '/mnt/hgfs':
        ensure => directory,
        }
      }
    }

    default: {
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

      case $::operatingsystemrelease {

        default: {
          file { "${root_home}/${tools_iso}":
            ensure  => absent,
            require => Exec[ 'remove /tmp/vmtools' ],
          }
        }
      }

      file_line { "remove /etc/fstab /tmp/vmtools":
        path    => '/etc/fstab',
        line    => '#/tmp/vmtools removed',
        match   => '/tmp/vmtools',
        require => Exec[ 'remove /tmp/vmtools' ],
      }
    }
  }
}
