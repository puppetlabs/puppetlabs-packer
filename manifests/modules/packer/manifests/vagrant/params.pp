# == Class: packer::vagrant::params
#
# A define that manages vagrand praramters
#
class packer::vagrant::params {

  case $::osfamily {
    debian, redhat: {
      $home_base    = '/home'
      $sudoers_file = '/etc/sudoers'
    }

    default: {
      fail( "Unsupported platform: ${::osfamily}/${::operatingsystem}" )
    }
  }

}
