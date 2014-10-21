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
