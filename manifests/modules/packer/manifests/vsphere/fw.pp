class packer::vsphere::fw {

  if ($::osfamily == 'RedHat')
  and ($::operatingsystemmajrelease in ['6', '7']) {
    class { 'firewall':
      ensure => stopped,
    }
  }

  # RHEL 8 comes with firewalld, we need this specific declaration because puppetlabs-firewall only manages iptables
  if ($::osfamily == 'RedHat')
  and ($::operatingsystemmajrelease == '8') {
    service { "firewalld":
      ensure => stopped,
      enable => false
    }
  }
}
