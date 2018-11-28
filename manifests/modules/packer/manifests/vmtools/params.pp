class packer::vmtools::params {
  
  case $::osfamily{
    'Darwin' :{
      $unmount_command = 'hdiutil unmount /tmp/vmtools ; rmdir /tmp/vmtools'
    }
    default : {
      $unmount_command = 'umount /tmp/vmtools ; rmdir /tmp/vmtools' 
    }
  }


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

    'Darwin' : {
      $root_home = '/var/root'
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
      }
      elsif $::osfamily == 'Darwin' {
        $tools_iso = 'darwin.iso'
      }

      else {
        $tools_iso   = 'linux.iso'
      }

      if $::osfamily == 'Solaris' {
        $install_cmd = 'tar zxf /tmp/vmtools/vmware-solaris-*.tar.gz && /tmp/vmware-tools-distrib/vmware-install.pl --default && rm -rf /tmp/vmware-tools-distrib'
      }
      elsif $::osfamily == 'Darwin' {
        $install_cmd = 'installer -pkg /tmp/vmtools/Install\ VMware\ Tools.app/Contents/Resources/VMware\ Tools.pkg -target /'
      }
       else {
        $install_cmd = 'tar zxf /tmp/vmtools/VMwareTools-*.tar.gz && /tmp/vmware-tools-distrib/vmware-install.pl --default && rm -rf /tmp/vmware-tools-distrib'
      }
    }

    default: {
      fail( "Unsupported provisioner: ${::provisioner}" )
    }
  }

}
