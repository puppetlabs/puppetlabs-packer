# == Class: packer::fw
#
# A define that manages firewall
#
class packer::vsphere::fw {

  if ($facts['osfamily'] == 'RedHat')
  and ($facts['operatingsystemmajrelease'] in ['6', '7']) {
    class { 'firewall':
      ensure => stopped,
    }
  }

  # RHEL 8 comes with firewalld, we need this specific declaration because puppetlabs-firewall only manages iptables
  if ($facts['osfamily'] == 'RedHat')
  and ($facts['operatingsystemmajrelease'] in ['8', '9']) {
    service { 'firewalld':
      ensure => stopped,
      enable => false
    }
  }
}
