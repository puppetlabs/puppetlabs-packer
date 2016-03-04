class packer::vmtools::params {

  case $::osfamily {
    'Redhat' : {
      $root_home = '/root'
      $required_packages = [ 'kernel-devel', 'gcc' ]
    }

    'Debian' : {
      $root_home = '/root'
      $required_packages = [ "linux-headers-${::kernelrelease}" ]
    }

    default : {
      fail( "Unsupported platform: ${::osfamily}/${::operatingsystem}" )
    }
  }

  case $::provisioner {
    virtualbox: {
      $tools_iso   = 'VBoxGuestAdditions.iso'
      $install_cmd = 'sh /tmp/vmtools/VBoxLinuxAdditions.run --nox11 ; true'
    }

    vmware: {
      $tools_iso   = 'linux.iso'
      $install_cmd = 'tar zxf /tmp/vmtools/VMwareTools-*.tar.gz -C /tmp/ ; /tmp/vmware-tools-distrib/vmware-install.pl --force-install ; rm -rf /tmp/vmware-tools-distrib'
    }

    default: {
      fail( "Unsupported provisioner: ${::provisioner}" )
    }
  }

}
