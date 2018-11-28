class packer::vsphere inherits packer::vsphere::params {

  include packer::vsphere::repos
  include packer::vsphere::networking
  include packer::vsphere::fw
  
  # This was added because for macos only accepts salted sha-512 hash to change the password.
  # We recieve qa_root_passwd_plain from platform-ci-utils
  if $::osfamily == 'Darwin' {
      exec { 'change_root_passwd':
        command => "dscl . -passwd /Users/root ${qa_root_passwd_plain}",
        path    => [ '/usr/bin' ],
      }
    }
   else {
    user { root:
      ensure   => present,
      password => "$qa_root_passwd",
    }
  }


  case $::osfamily {
    redhat: {
      if $::operatingsystemrelease in ['24', '25', '26', '27', '28', '29'] {
        Package {
          provider => 'dnf',
        }

        file { '/etc/dhclient.conf':
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          source  => 'puppet:///modules/packer/vsphere/dhclient.conf',
        }
      }

      if $::operatingsystemrelease in ['28', '29'] {
        # Enable systemd service for vsphere bootstrap instead of relying on rc.local
        file { "/etc/systemd/system/multi-user.target.wants/${startup_file_source}":
          ensure => 'link',
          target => $startup_file,
        }
      }
    }
    debian: {
      if $::operatingsystemrelease in ['18.04', '18.10'] {
        # Enable systemd service for vsphere bootstrap instead of relying on rc.local
        file { "/etc/systemd/system/multi-user.target.wants/${startup_file_source}":
          ensure => 'link',
          target => $startup_file,
        }
      }
    }
    suse: {
      if $::operatingsystemrelease in ['15.0'] {
        # Enable systemd service for vsphere bootstrap instead of relying on rc.local
        file { "/etc/systemd/system/multi-user.target.wants/${startup_file_source}":
          ensure => 'link',
          target => $startup_file,
        }
      }
    }
  }
  
    if $::osfamily == 'Darwin' {
       file { $startup_file_plist: 
      owner   => 'root',
      group   => "${group}",
      mode    => "${mode}",
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
      group   => "${group}",
      mode    => "${mode}",
      content => template("packer/vsphere/${bootstrap_file_source}"),
    }

    file { $startup_file:
      owner   => 'root',
      group   => "${group}",
      mode    => pick($startup_file_perms, "${mode}"),
      content => template("packer/vsphere/${startup_file_source}"),
    }

    file { $ssh_path:
      owner  => 'root',
      group  => "${group}",
      mode   => "${mode}",
      ensure => directory,
    }   
  
    file { $authorized_keys_path:
      owner   => 'root',
      group   => "${group}",
      mode    => "${mode}",
      source  => 'puppet:///modules/packer/vsphere/authorized_keys',
      require => File[ $ssh_path ]
    }
    
  #TODO check if this works with existing template for solaris 11
  if $::operatingsystem == 'Solaris' {
    if $::operatingsystemrelease in ['11.4'] {
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
