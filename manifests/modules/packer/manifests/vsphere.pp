class packer::vsphere inherits packer::vsphere::params {

  include packer::vsphere::repos
  include packer::vsphere::networking
  include packer::vsphere::fw

  user { root:
    ensure   => present,
    password => "$qa_root_passwd"
  }

  package { $ruby_package:
    ensure => present,
  }

  file { $bootstrap_file:
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    content => template("packer/vsphere/${bootstrap_file_source}"),
  }

  file { $startup_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("packer/vsphere/${startup_file_source}"),
  }

  file { '/root/.ssh':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    ensure => directory,
  }

  file { '/root/.ssh/authorized_keys':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/packer/vsphere/authorized_keys',
    require => File[ '/root/.ssh' ]
  }

}
