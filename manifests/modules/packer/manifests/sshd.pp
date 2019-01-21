# == Class: packer::sshd
#
# A define that manages SSHD server
#
class packer::sshd {

  if ($::operatingsystem == 'Solaris') and ($::operatingsystemrelease in ['11.2']) {
    # In version 11.2 UseDNS option is invalid so we remove it from options.
    class { 'ssh::server':
      storeconfigs_enabled => false,
      options              => {
        'PermitRootLogin'      => 'yes',
        'GSSAPIAuthentication' => 'no',
      },
    }
  }
  else {
    class { 'ssh::server':
      storeconfigs_enabled => false,
      options              => {
        'PermitRootLogin'      => 'yes',
        'UseDNS'               => 'no',
        'GSSAPIAuthentication' => 'no',
      },
    }
  }
}
