class packer::vsphere::networking inherits packer::networking::params {

  if $::osfamily != 'Darwin' {
  class { 'network':
    config_file_notify => '',
    }
  }
  case $::osfamily {
    debian: {
      if $::operatingsystemrelease in ['15.10'] {
        network::interface { 'ens32':
          enable_dhcp   => true,
        }
      }
      if ($::operatingsystemmajrelease in ['8', '9', '16.04', '18.04', '18.10']) {
        network::interface { 'ens160':
          enable_dhcp   => true,
        }
      }
    }

    redhat: {
      if ($::operatingsystemmajrelease in ['7', '8']) {
        if ( $interface_script != undef ) {
          file { $interface_script:
            ensure => absent,
          }
        }
        if $::operatingsystemmajrelease == '7' {
          network::interface { 'ens160':
            enable_dhcp   => true,
          }
        }
      }
      if ($::operatingsystem == 'Fedora') {
        if ( $interface_script != undef ) {
          file { $interface_script:
            ensure => absent,
          }
        }
      }
    }

    suse: {
      if ($::operatingsystemmajrelease == '15') {
        file { '/etc/wicked/dhcp4.xml':
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
          source => 'puppet:///modules/packer/vsphere/dhcp4.xml',
        }
      }
    }
  }
}
