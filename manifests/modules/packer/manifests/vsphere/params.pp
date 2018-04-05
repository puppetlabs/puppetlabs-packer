class packer::vsphere::params {

  # NOTE: The os_mirror parameter should be removed once all of the repos
  # are moved over to artifactory
  $repo_mirror = 'https://artifactory.delivery.puppetlabs.net/artifactory'
  $os_mirror = 'http://osmirror.delivery.puppetlabs.net'
  $loweros     = downcase($::operatingsystem)

  case $::operatingsystem {
    'Ubuntu': {
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'ubuntu.rb.erb'
      if $::operatingsystemrelease in ['18.04'] {
        $startup_file          = '/etc/systemd/system/vsphere.bootstrap.service'
        $startup_file_source   = 'vsphere.bootstrap.service'
      } else {
        $startup_file          = '/etc/rc.local'
        $startup_file_source   = 'rc.local'
      }
      if $facts[os][release] in ['12.04', '14.04'] {
        $periodic_file         = '/etc/apt/apt.conf.d/02periodic'
      }
      else {
        $periodic_file         = '/etc/apt/apt.conf.d/10periodic'
      }
      if $::operatingsystemrelease in ['10.04', '12.04'] {
        $ruby_package          = [ 'ruby', 'rubygems' ]
      }
      else {
        $ruby_package          = [ 'ruby', 'rubygems-integration' ]
      }
      $repo_name             = 'ubuntu__remote'
      $repo_list             = 'main restricted universe multiverse'
      $security_repo_name    = 'ubuntu__remote'
      $security_release      = "${lsbdistcodename}-security"
      $updates_release       = "${lsbdistcodename}-updates"
    }

    'Debian': {
      $startup_file          = '/etc/rc.local'
      $startup_file_source   = 'rc.local'
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'debian.rb.erb'
      if $facts[os][release] in ['7', '8'] {
        $periodic_file         = '/etc/apt/apt.conf.d/02periodic'
      }
      else {
        $periodic_file         = '/etc/apt/apt.conf.d/10periodic'
      }
      $ruby_package          = [ 'ruby' ]
      $repo_name             = 'debian'
      $repo_list             = 'main contrib non-free'
      $security_repo_name    = 'debian-security'
      $security_release      = "${lsbdistcodename}/updates"
      $updates_release       = "${lsbdistcodename}-updates"
    }

    'CentOS', 'Redhat', 'Scientific', 'OracleLinux': {
      $startup_file          = '/etc/rc.d/rc.local'
      $startup_file_source   = 'rc.local'
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'redhat.rb.erb'
      $ruby_package          = [ 'ruby' ]
      $gpgkey                = "RPM-GPG-KEY-${::operatingsystem}-${::operatingsystemmajrelease}"
    }

    'SLES': {
      $startup_file          = '/etc/rc.d/after.local'
      $startup_file_source   = 'rc.local'
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'sles.rb.erb'
      $ruby_package          = [ 'ruby' ]
      $gpgkey                = "RPM-GPG-KEY-${::operatingsystem}-${::operatingsystemmajrelease}"
    }

    'Fedora': {
      $startup_file          = '/etc/rc.d/rc.local'
      $startup_file_source   = 'rc.local'
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'redhat.rb.erb'
      $ruby_package          = [ 'ruby', 'rubygems' ]
      $gpgkey                = "RPM-GPG-KEY-${::operatingsystemmajrelease}-${loweros}"
    }

    default: {
      fail( "Unsupported platform: ${::osfamily}/${::operatingsystem}" )
    }
  }

}
