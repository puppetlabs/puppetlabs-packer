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

    'Suse' : {
      $root_home = '/root'
      $required_packages = [ 'kernel-devel', 'gcc' ]
    }

    'Solaris' : {
      $root_home = '/root'
      $required_packages = []
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
      if $::osfamily == 'Solaris' {
        $tools_iso   = 'solaris.iso'
      } else {
        $tools_iso   = 'linux.iso'
      }

      if $::osfamily == 'Solaris' {
        $install_cmd = 'tar zxf /tmp/vmtools/vmware-solaris-*.tar.gz && /tmp/vmware-tools-distrib/vmware-install.pl --default && rm -rf /tmp/vmware-tools-distrib'
      } else {
        $install_cmd = 'tar zxf /tmp/vmtools/VMwareTools-*.tar.gz && /tmp/vmware-tools-distrib/vmware-install.pl --default && rm -rf /tmp/vmware-tools-distrib'
      }
    }

    default: {
      fail( "Unsupported provisioner: ${::provisioner}" )
    }
  }

}
