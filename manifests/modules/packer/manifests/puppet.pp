class packer::puppet {

  case $::osfamily {
    debian: {
      include apt

      apt::source { 'puppetlabs':
        location => 'http://apt.puppetlabs.com',
        repos    => 'main dependencies',
        key        => '4BD6EC30',
        key_server => 'pgp.mit.edu',
      }

      package { 'puppet':
        ensure  => present,
        require => Apt::Source[ 'puppetlabs' ],
      }
    }

    redhat: {
      class { 'puppetlabs_yum': }

      package { 'puppet':
        ensure   => present,
        provider => 'yum',
        require  => Class[ 'puppetlabs_yum' ],
      }
    }

    default: {
      fail( "Unsupported platform: ${::osfamily}/${::operatingsystem}" )
    }
  }

}
