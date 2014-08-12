class packer::vsphere inherits packer::vsphere::params {

  package { $ruby_package:
    ensure => present,
  }

  package { 'facter':
    ensure   => present,
    provider => 'gem',
    require  => Package[ $ruby_package ],
  }

  package { 'nokogiri':
    ensure   => '1.5.9',
    provider => 'gem',
    require  => Package[ $ruby_package ],
  }

  package { 'rbvmomi':
    ensure   => '1.6.0',
    provider => 'gem',
    require  => Package[ 'nokogiri' ],
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
