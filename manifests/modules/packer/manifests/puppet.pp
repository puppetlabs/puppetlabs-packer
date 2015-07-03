class packer::puppet {

  case $::osfamily {
    debian: {
      include apt

      apt::source { 'puppetlabs-pc1':
        location   => 'http://apt.puppetlabs.com',
        repos      => 'PC1',
        key        => '4BD6EC30',
        key_server => 'pgp.mit.edu',
      }

      package { 'puppet-agent':
        ensure  => present,
        require => Apt::Source[ 'puppetlabs-pc1' ],
      }
    }

    redhat: {
      yumrepo { 'puppetlabs-pc1':
        baseurl  => 'http://yum.puppetlabs.com/el/$releasever/PC1/$basearch',
        descr    => 'Puppet Labs PC1 Repository el $releasever - $basearch',
        gpgkey   => 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
        enabled  => '1',
        gpgcheck => '1',
      }

      package { 'puppet-agent':
        ensure  => present,
        require => Yumrepo[ 'puppetlabs-pc1' ],
      }
    }

    default: {
      fail( "Unsupported platform: ${::osfamily}/${::operatingsystem}" )
    }
  }

}
