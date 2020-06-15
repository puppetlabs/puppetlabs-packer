# == Class: packer::vsphere::params
#
# Default vsphere parameter values for the packer module
#
class packer::vsphere::params {

  # NOTE: The os_mirror parameter should be removed once all of the repos
  # are moved over to artifactory
  $repo_mirror = 'https://artifactory.delivery.puppetlabs.net/artifactory'
  $os_mirror = 'http://osmirror.delivery.puppetlabs.net'
  $loweros     = downcase($facts['operatingsystem'])

  case $facts['operatingsystem'] {
    'Darwin': {
      $group = 'admin'
      $mode = '0644'
      $ssh_path='/var/root/.ssh'
      $authorized_keys_path='/var/root/.ssh/authorized_keys'
    }
    default: {
      $group = 'root'
      $mode = '0755'
      $authorized_keys_path='/root/.ssh/authorized_keys'
      $ssh_path='/root/.ssh'
    }
  }

  case $facts['operatingsystem'] {
    'Ubuntu': {
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'ubuntu.rb.erb'
      if $facts['operatingsystemrelease'] in ['18.04', '18.10', '20.04'] {
        $startup_file          = '/etc/systemd/system/vsphere.bootstrap.service'
        $startup_file_source   = 'vsphere.bootstrap.service'
        $startup_file_perms    = '0644'
      }
      else {
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
      $security_release      = "${facts['lsbdistcodename']}-security"
      $updates_release       = "${facts['lsbdistcodename']}-updates"
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
      $repo_name             = 'debian__remote'
      $repo_list             = 'main contrib non-free'
      $security_repo_name    = 'debian_security__remote'
      $security_release      = "${facts['lsbdistcodename']}/updates"
      $updates_release       = "${facts['lsbdistcodename']}-updates"
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
      if $facts['operatingsystemmajrelease'] in ['15'] {
        $startup_file          = '/etc/systemd/system/vsphere.bootstrap.service'
        $startup_file_source   = 'vsphere.bootstrap.service'
        $startup_file_perms    = '0644'
      } else {
        $startup_file          = '/etc/rc.d/after.local'
        $startup_file_source   = 'rc.local'
      }
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'sles.rb.erb'
      $ruby_package          = [ 'ruby' ]
      $gpgkey                = "RPM-GPG-KEY-${::operatingsystem}-${::operatingsystemmajrelease}"
    }

    'Fedora': {
      if $facts['operatingsystemrelease'] in ['28', '29', '30', '31', '32'] {
        $startup_file          = '/etc/systemd/system/vsphere.bootstrap.service'
        $startup_file_source   = 'vsphere.bootstrap.service'
        $startup_file_perms    = '0644'
      } else {
        $startup_file          = '/etc/rc.d/rc.local'
        $startup_file_source   = 'rc.local'
      }
      $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
      $bootstrap_file_source = 'redhat.rb.erb'
      $ruby_package          = [ 'ruby', 'rubygems' ]
      $gpgkey                = "RPM-GPG-KEY-${::operatingsystemmajrelease}-${loweros}"
    }

    # TODO check if this can work with Solaris 11 main template
    'Solaris': {
      if $facts['operatingsystemrelease'] in ['11.4', '11.2'] {
        $ruby_package          = [ 'ruby' ]
        $bootstrap_file_source = 'solaris.rb.erb'
        $bootstrap_file        = '/etc/vsphere-bootstrap.rb'
        $startup_file          = '/etc/init.d/rc.local'
        $startup_file_source   = 'rc.local'
      }
    }

    'Darwin' : {
      $bootstrap_file_source     = 'osx.rb.erb'
      $bootstrap_file            = '/etc/vsphere-bootstrap.rb'
      $startup_file              = '/etc/rc.local'
      $startup_file_source       = 'rc.local'
      $startup_file_perms        = '0755'
      $startup_file_plist        = '/Library/LaunchDaemons/local.localhost.startup.plist'
      $startup_file_plist_source = 'local.localhost.startup.plist'
    }

    default: {
      fail( "Unsupported platform: ${::osfamily}/${::operatingsystem}" )
    }
  }

}
