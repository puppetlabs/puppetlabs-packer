class packer::vsphere::networking inherits packer::networking::params {

  class { 'network':
    config_file_notify => '',
  }

  case $::osfamily {
    debian: {
      if $::operatingsystemrelease in ['15.10', '16.04'] {
        network::interface { 'ens32':
          enable_dhcp   => true,
      }
    }
  }

    redhat: {
      if ($::operatingsystemmajrelease == '7') {
        if ( $interface_script != undef ) {
          file { $interface_script:
            ensure => absent,
          }
        }
        network::interface { 'ens32':
          enable_dhcp   => true,
        }
      }
    }
  }
}
