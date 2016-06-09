class bitvise_sshd::service ()
{
  # Start BitVise Service
  service { 'bitvise_service':
    ensure => running,
    enable => true,
    name   => 'BvSshServer',
    require => Package['Bitvise SSH Server 6.45 (remove only)']
  }
}
