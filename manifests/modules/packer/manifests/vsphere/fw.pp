class packer::vsphere::fw {

  if ($::osfamily == 'RedHat')
  and ($::operatingsystemmajrelease in ['6', '7']) {
    class { 'firewall':
      ensure => stopped,
    }
  }
}
