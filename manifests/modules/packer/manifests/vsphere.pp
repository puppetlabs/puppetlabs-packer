class packer::vsphere inherits packer::vsphere::params {

  package { 'ruby-dev':
    ensure => present,
  }

  package { 'facter':
    ensure   => present,
    provider => 'gem',
  }

  package { 'rbvmomi':
    ensure   => '1.6.0',
    provider => 'gem',
    require  => Package[ 'ruby-dev' ],
  }

  file { $bootstrap_file:
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/packer/vsphere/${bootstrap_file_source}",
  }

  file { $startup_file:
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/packer/vsphere/${startup_file_source}",
  }

}
