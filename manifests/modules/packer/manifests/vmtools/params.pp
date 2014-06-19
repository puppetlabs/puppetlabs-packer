class packer::vmtools::params {

  case $::osfamily {
    debian, redhat: {
      $root_home = '/root'
    }

    redhat: {
      $required_packages = [ 'kernel-devel' ]
    }

    default: {
      fail( "Unsupported platform: ${::osfamily}/${::operatingsystem}" )
    }
  }

  case $::provisioner {
    virtualbox: {
      $tools_iso   = 'VBoxGuestAdditions_4.3.12.iso'
      $install_cmd = 'sh /tmp/vmtools/VBoxLinuxAdditions.run --nox11 ; true'
    }

    vmware: {
      $tools_iso   = 'linux.iso'
      $install_cmd = 'tar zxf /tmp/vmtools/VMwareTools-*.tar.gz -C /tmp/ ; /tmp/vmware-tools-distrib/vmware-install.pl --default ; rm -rf /tmp/vmware-tools-distrib'
    }

    default: {
      fail( "Unsupported provisioner: ${::provisioner}" )
    }
  }

}
