# == Class: packer::vsphere
#
# A define that manages vsphere
#
class packer::vsphere(
  Optional[String] $group = $packer::vsphere::params::group,
  Optional[String] $mode = $packer::vsphere::params::mode,
  Optional[String] $startup_file = $packer::vsphere::params::startup_file,
  Optional[String] $startup_file_source = $packer::vsphere::params::startup_file_source,
  Optional[String] $startup_file_plist = $packer::vsphere::params::startup_file_plist,
  Optional[String] $startup_file_plist_source = $packer::vsphere::params::startup_file_plist_source,
  Optional[String] $startup_file_perms = $packer::vsphere::params::startup_file_perms,
  Optional[Tuple] $ruby_package = $packer::vsphere::params::ruby_package,
  Optional[String] $ssh_path = $packer::vsphere::params::ssh_path,
  Optional[String] $authorized_keys = $packer::vsphere::params::authorized_keys,
  Optional[String] $authorized_keys_path = $packer::vsphere::params::authorized_keys_path,
  Optional[String] $bootstrap_file = $packer::vsphere::params::bootstrap_file,
  Optional[String] $bootstrap_file_source = $packer::vsphere::params::bootstrap_file_source
) inherits packer::vsphere::params {

  include packer::vsphere::repos
  include packer::vsphere::updates
  include packer::vsphere::networking
  include packer::vsphere::fw

  # This was added because for macos only accepts salted sha-512 hash to change the password.
  # We recieve qa_root_passwd_plain from platform-ci-utils
  if $facts['osfamily'] == 'Darwin' {
      exec { 'change_root_passwd':
        command => "dscl . -passwd /Users/root ${facts['qa_root_passwd_plain']}",
        path    => [ '/usr/bin' ],
      }
    }
    else {
    user { 'root':
      ensure   => present,
      password => $facts['qa_root_passwd'],
    }
  }


  case $facts['osfamily'] {
    redhat: {
      if $facts['operatingsystemrelease'] in ['24', '25', '26', '27', '28', '29', '30', '31', '32'] {
        Package {
          provider => 'dnf',
        }

        file { '/etc/dhclient.conf':
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
          source => 'puppet:///modules/packer/vsphere/dhclient.conf',
        }
      }

      if $facts['operatingsystemrelease'] in ['28', '29', '30', '31', '32'] {
        # Enable systemd service for vsphere bootstrap instead of relying on rc.local
        file { "/etc/systemd/system/multi-user.target.wants/${startup_file_source}":
          ensure => 'link',
          target => $startup_file,
        }
      }
    }
    debian: {
      if $facts['operatingsystemrelease'] in ['18.04', '18.10', '20.04'] {
        # Enable systemd service for vsphere bootstrap instead of relying on rc.local
        file { "/etc/systemd/system/multi-user.target.wants/${startup_file_source}":
          ensure => 'link',
          target => $startup_file,
        }
      }
    }
    suse: {
      if $facts['operatingsystemrelease'] in ['15.0'] {
        # Enable systemd service for vsphere bootstrap instead of relying on rc.local
        file { "/etc/systemd/system/multi-user.target.wants/${startup_file_source}":
          ensure => 'link',
          target => $startup_file,
        }
      }
    }
    default:{    }
  }

    if $facts['osfamily'] == 'Darwin' {
        file { $startup_file_plist:
      owner   => 'root',
      group   => $group,
      mode    => $mode,
      content => template("packer/vsphere/${startup_file_plist_source}")
      }
    }
    else {
      package { $ruby_package:
      ensure => present,
      }
    }

    file { $bootstrap_file:
      owner   => 'root',
      group   => $group,
      mode    => $mode,
      content => template("packer/vsphere/${bootstrap_file_source}"),
    }

    file { $startup_file:
      owner   => 'root',
      group   => $group,
      mode    => pick($startup_file_perms, $mode),
      content => template("packer/vsphere/${startup_file_source}"),
    }

    file { $ssh_path:
      ensure => directory,
      group  => $group,
      mode   => $mode,
      owner  => 'root',
    }

    file { $authorized_keys_path:
      owner   => 'root',
      group   => $group,
      mode    => $mode,
      source  => 'puppet:///modules/packer/vsphere/authorized_keys',
      require => File[ $ssh_path ]
    }

  #TODO check if this works with existing template for solaris 11
  if $facts['operatingsystem'] == 'Solaris' {
    if $facts['operatingsystemrelease'] in ['11.4', '11.2'] {
      file { "/etc/rc2.d/S99${startup_file_source}":
          ensure => 'link',
          target => $startup_file,
        }
      file { "/etc/rc0.d/K99${startup_file_source}":
          ensure => 'link',
          target => $startup_file,
        }
    }
  }

}
