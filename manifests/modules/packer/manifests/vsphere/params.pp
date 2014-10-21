class packer::vsphere::params {

  case $::osfamily {
    debian: {
      $startup_file          = '/etc/rc.local'
      $startup_file_source   = 'rc.local'
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'debian.rb'
      $ruby_package          = 'ruby-dev'
    }

    redhat: {
      $startup_file          = '/etc/rc.d/rc.local'
      $startup_file_source   = 'rc.local'
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'redhat.rb'
      $ruby_package          = [ 'libxml2-devel', 'libxslt-devel', 'ruby-devel', 'rubygems' ]
    }

    default: {
      fail( "Unsupported platform: ${::osfamily}/${::operatingsystem}" )
    }
  }

}
