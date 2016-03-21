class packer::vsphere::fw {

  if ($::osfamily == 'RedHat')
  and ($::operatingsystemmajrelease == '7') {
    class { 'firewall':
      ensure => stopped,
    }
  }
}
