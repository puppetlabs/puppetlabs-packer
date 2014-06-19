class packer::vsphere::params {

  case $::osfamily {
    debian: {
      $startup_file          = '/etc/rc.local'
      $startup_file_source   = 'rc.local'
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'debian.rb'
    }

    default: {
      fail( "Unsupported platform: ${::osfamily}/${::operatingsystem}" )
    }
  }

}
