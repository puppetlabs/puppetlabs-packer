# == Class: packer::vmtools
#
# A define that manages vmtools installation
#
class packer::vmtools(
  Optional[Tuple]  $required_packages = $packer::vmtools::params::required_packages,
  Optional[String]  $root_home = $packer::vmtools::params::root_home,
  Optional[String]  $tools_iso = $packer::vmtools::params::tools_iso,
  Optional[String]  $unmount_command = $packer::vmtools::params::unmount_command,
  Optional[String]  $install_cmd = $packer::vmtools::params::install_cmd

) inherits packer::vmtools::params {

  $vmtools_mountpoint = '/tmp/vmtools'
  # At some point it's going to become more worthwhile to flip this so
  # installing open-vm-tools is the default.
  if ( ($facts['osfamily'] == 'debian' and $facts['operatingsystemmajrelease'] in ['7', '8', '9', '10', '11', '16.04', '14.04', '18.04', '18.10', '20.04']) or
        ($facts['osfamily'] == 'redhat' and $facts['operatingsystemmajrelease'] in ['7', '8', '25', '26', '27', '28', '29', '30', '31', '32', '34']) or
        ($facts['osfamily'] == 'suse' and $facts['operatingsystemmajrelease'] in ['15'])
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

    file { $vmtools_mountpoint:
      ensure => directory,
    }


    if $facts['osfamily'] == 'Solaris' {
      mount { '/tmp/vmtools':
        ensure      => mounted,
        device      => "${root_home}/${tools_iso}",
        fstype      => 'hsfs',
        remounts    => false,
        blockdevice => '/dev/rdsk/c0d0s0',
        atboot      => true,
        options     => 'ro,loop',
        require     => File[ $vmtools_mountpoint ],
        before      => Exec[ 'install vmtools' ],
      }
    }
    # For macos we do exec resource to mount vmtools iso
    elsif $facts['osfamily'] == 'Darwin'     {
      exec { 'mount cdrom':
        command => "hdiutil mount ${root_home}/${tools_iso} -mountpoint ${vmtools_mountpoint}",
        path    => [ '/bin', '/usr/bin' ],
        cwd     => '/var/root',
        require => File[ $vmtools_mountpoint ],
        before  => Exec[ 'install vmtools' ],
      }
    }
      else {
      mount { '/tmp/vmtools':
        ensure  => mounted,
        device  => "${root_home}/${tools_iso}",
        fstype  => 'iso9660',
        options => 'ro,loop',
        require => File[ $vmtools_mountpoint ],
        before  => Exec[ 'install vmtools' ],
      }
    }

    exec { 'install vmtools':
      command => $install_cmd,
      path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ],
      cwd     => '/tmp/',
    }

    if $facts['osfamily'] == 'Solaris' {
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
      command => $unmount_command,
      path    => [ '/sbin', '/usr/sbin', '/bin', '/usr/bin' ],
      onlyif  => 'test -d /tmp/vmtools',
      require => Exec[ 'install vmtools' ],
    }

    file { "${root_home}/${tools_iso}":
      ensure  => absent,
      require => Exec[ "remove ${vmtools_mountpoint}" ],
    }

    if $facts['osfamily'] == 'Solaris' {
      $fstab_path = '/etc/vfstab'
    } else {
      $fstab_path = '/etc/fstab'
    }
    if $facts['osfamily'] != 'Darwin'{
    file_line { 'remove fstab /tmp/vmtools':
      path    => $fstab_path,
      line    => '#/tmp/vmtools removed',
      match   => '/tmp/vmtools',
      require => Exec[ 'remove /tmp/vmtools' ],
      }
    }
  }
}
