# == Class: packer::networking::params
#
# A define that manages networking paramterers
#
class packer::networking::params {

  case $facts['osfamily'] {
    debian: {
      $udev_rule        = '/etc/udev/rules.d/70-persistent-net.rules'
      $udev_rule_gen    = '/lib/udev/rules.d/75-persistent-net-generator.rules'
      $interface_script = undef
    }

    redhat: {
      case $facts['operatingsystemrelease'] {
        '7.0', '7.0.1406', '7.1.1503', '7.2.1511', '7.2', '7.3.1611', '7.4.1708', '7.5.1804', '7.6.1810', '8.0', '8.0.1905', '8.3.2011', '8.4', '9.0': {
          case $::provisioner {

            'virtualbox': { $interface_script = '/etc/sysconfig/network-scripts/ifcfg-enp0s3' }
            'vmware':     {
                $network_name = chomp(generate('/usr/bin/ls', '/sys/class/net', '-I', 'lo'))
                $interface_script = "/etc/sysconfig/network-scripts/ifcfg-${network_name}"
              }
            'libvirt':    { $interface_script = '/etc/sysconfig/network-scripts/ifcfg-eth0' }
            default : {}
          }

          $udev_rule     = '/etc/udev/rules.d/70-persistent-net.rules'
          $udev_rule_gen = '/lib/udev/rules.d/75-persistent-net-generator.rules'
        }

        '5.10', '5.11': {
          $interface_script = '/etc/sysconfig/network-scripts/ifcfg-eth0'
          $udev_rule        = '/etc/udev/rules.d/70-persistent-net.rules'
        }

        '25', '26', '27', '28': {
          case $::provisioner {
            'virtualbox': { $interface_script = '/etc/sysconfig/network-scripts/ifcfg-enp0s3' }
            'libvirt':    { $interface_script = '/etc/sysconfig/network-scripts/ifcfg-ens4' }
            'vmware':     { $interface_script = '/etc/sysconfig/network-scripts/ifcfg-lo' }
            default: {}
          }
          $udev_rule     = undef
          $udev_rule_gen = undef
        }
        '29', '30', '31', '32', '34': {
          $interface_script = undef
          $udev_rule        = undef
          $udev_rule_gen    = undef
        }

        default: {
          $interface_script = '/etc/sysconfig/network-scripts/ifcfg-eth0'
          $udev_rule        = '/etc/udev/rules.d/70-persistent-net.rules'
          $udev_rule_gen    = '/lib/udev/rules.d/75-persistent-net-generator.rules'
        }
      }
    }
    suse: {
      $interface_script = '/etc/sysconfig/network/ifcfg-eth0'
      $udev_rule        = '/etc/udev/rules.d/70-persistent-net.rules'
      $udev_rule_gen    = '/lib/udev/rules.d/75-persistent-net-generator.rules'
    }
    solaris: {
      $udev_rule        = undef
      $udev_rule_gen    = undef
      $interface_script = undef

    }
    darwin: {
      $udev_rule        = undef
      $udev_rule_gen    = undef
      $interface_script = undef
    }
    default: {
      fail( "Unsupported platform: ${::osfamily}/${::operatingsystem}" )
    }
  }

}
