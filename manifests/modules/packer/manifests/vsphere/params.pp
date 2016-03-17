class packer::vsphere::params {

  $repo_mirror = 'http://osmirror.delivery.puppetlabs.net'
  $loweros     = downcase($::operatingsystem)

  case $::operatingsystem {
    'Ubuntu': {
      $startup_file          = '/etc/rc.local'
      $startup_file_source   = 'rc.local'
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'ubuntu.rb.erb'
      $ruby_package          = [ 'ruby' ]
      $repo_name             = 'ubuntu'
      $repo_list             = 'main restricted universe multiverse'
      $security_repo_name    = 'ubuntu'
      $security_release      = "${lsbdistcodename}-security"
      $updates_release       = "${lsbdistcodename}-updates"
    }

    'Debian': {
      $startup_file          = '/etc/rc.local'
      $startup_file_source   = 'rc.local'
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'debian.rb.erb'
      $ruby_package          = [ 'ruby' ]
      $repo_name             = 'debian'
      $repo_list             = 'main contrib non-free'
      $security_repo_name    = 'debian-security'
      $security_release      = "${lsbdistcodename}/updates"
      $updates_release       = "${lsbdistcodename}-updates"
    }

    'CentOS', 'Redhat', 'Scientific': {
      $startup_file          = '/etc/rc.d/rc.local'
      $startup_file_source   = 'rc.local'
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'redhat.rb.erb'
      $ruby_package          = [ 'ruby' ]
      $gpgkey                = "RPM-GPG-KEY-${::operatingsystem}-${::operatingsystemmajrelease}"
    }

    'Fedora': {
      $startup_file          = '/etc/rc.d/rc.local'
      $startup_file_source   = 'rc.local'
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'redhat.rb.erb'
      $ruby_package          = [ 'ruby' ]
      $gpgkey                = "RPM-GPG-KEY-${::operatingsystemmajrelease}-${loweros}"
    }

    default: {
      fail( "Unsupported platform: ${::osfamily}/${::operatingsystem}" )
    }
  }

}
