# == Class: packer::networking
#
# A define that manages networking
#
class packer::networking(
  $udev_rule = $packer::networking::params::udev_rule,
  $udev_rule_gen = $packer::networking::params::udev_rule_gen,
  $interface_script = $packer::networking::params::interface_script
) inherits packer::networking::params {

  if ( $udev_rule != undef ) {
    file { $udev_rule:
      ensure => absent,
    }
  }

  if ( $udev_rule_gen != undef ) {
    file { $udev_rule_gen:
      ensure => link,
      target => '/dev/null',
    }
  }

  if ( $interface_script != undef ) {
    file_line { "remove ${interface_script} hwaddr":
      path  => $interface_script,
      line  => '#HWADDR withheld',
      match => 'HWADDR',
    }
  }

}
