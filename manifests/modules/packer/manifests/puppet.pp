# == Class: packer::puppet
#
# A define that manages puppet
#
class packer::puppet {

  case $facts['osfamily'] {
    debian: {
      include apt

      apt::source { 'puppetlabs-pc1':
        location   => 'http://apt.puppetlabs.com',
        repos      => 'PC1',
        key        => '7F438280EF8D349F',
        key_server => 'pgp.mit.edu',
      }

      package { 'puppet-agent':
        ensure  => present,
        require => Apt::Source[ 'puppetlabs-pc1' ],
      }
    }

    redhat: {

        if $facts['operatingsystem'] == 'Fedora' {
          $ostype = 'fedora'
          $prefix = 'f'
        } elsif $facts['osfamily'] == 'RedHat' {
          $ostype = 'el'
          $prefix = ''
        }
        else {
          err('Unable to determine operating system information to assign yum repo.')
        }

      yumrepo { 'puppetlabs-pc1':
        baseurl  => "http://yum.puppetlabs.com/${ostype}/${prefix}\$releasever/PC1/\$basearch",
        descr    => "Puppet Labs PC1 Repository ${ostype} ${releasever} - \$basearch",
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

  file { '/etc/profile.d/append-puppetlabs-path.sh':
    mode    => '0644',
    content => 'PATH=$PATH:/opt/puppetlabs/bin',
  }

}
