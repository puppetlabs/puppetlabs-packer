class packer::sshd {

  class { 'ssh::server':
    storeconfigs_enabled => false,
    options => {
      'PermitRootLogin'      => 'yes',
      'UseDNS'               => 'no',
      'GSSAPIAuthentication' => 'no',
    },
  }

}
