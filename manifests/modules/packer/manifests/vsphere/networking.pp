# == Class: packer::networking
#
# A define that manages networking
#
class packer::vsphere::networking(
  Optional[String] $interface_script = $packer::vsphere::network::params::interface_script
) inherits packer::networking::params {

  if $facts['osfamily'] != 'Darwin' {
  class { 'network':
    config_file_notify => '',
    }
  }
  case $facts['osfamily'] {
    debian: {
      if $facts['operatingsystemrelease'] in ['15.10'] {
        network::interface { 'ens32':
          enable_dhcp   => true,
        }
      }
      if ($facts['operatingsystemmajrelease'] in ['8']) {
          network::interface { 'eth0':
          enable_dhcp   => true,
        }
      }
      if ($facts['operatingsystemmajrelease'] in ['9', '16.04']) {
        network::interface { 'ens160':
          enable_dhcp   => true,
        }
      }
      if $facts['operatingsystemmajrelease'] in ['10', 'bullseye/sid'] {
        network::interface { 'ens192':
          enable_dhcp   => true,
        }
      }
      # ubuntu '18.04', '18.10', '20.04' includes a /etc/netplan that already configures the network with dhcp. Adding a network::interface
      # here sets up two interfaces each with an IP. https://tickets.puppetlabs.com/browse/IMAGES-1217
    }

    redhat: {
      if ($facts['operatingsystemmajrelease'] in ['7', '8']) {
        if ( $interface_script != undef ) {
          file { $interface_script:
            ensure => absent,
          }
        }
        if $facts['operatingsystemmajrelease'] == '7' {
          network::interface { 'ens33':
            enable_dhcp   => true,
          }
        }
      }
      if ($facts['operatingsystem'] == 'Fedora') {
        if ( $interface_script != undef ) {
          file { $interface_script:
            ensure => absent,
          }
        }
      }
    }

    suse: {
      if ($facts['operatingsystemmajrelease'] == '15') {
        file { '/etc/wicked/dhcp4.xml':
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
          source => 'puppet:///modules/packer/vsphere/dhcp4.xml',
        }
      }
    }
    default: {}
  }
}
