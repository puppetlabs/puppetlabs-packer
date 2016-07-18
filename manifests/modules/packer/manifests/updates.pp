class packer::updates {

  $linux_pkgs = [
    'bash',
    'openssl',
  ]

  $debian_pkgs = [
    'libc6',
    'openssh-client',
    'openssh-server',
  ]

  $redhat_pkgs = [
    'glibc',
    'openssh',
  ]

  if $::osfamily == 'Debian' {
    if $::operatingsystemrelease in ['10.04'] {
      $pkgs_to_update = $linux_pkgs + $debian_pkgs + ['dhcp3-client']
    }
    else {
      $pkgs_to_update = $linux_pkgs + $debian_pkgs
    }
  } elsif $::osfamily == 'Redhat' {
    $pkgs_to_update = $linux_pkgs + $redhat_pkgs
  }

  package { $pkgs_to_update: ensure => latest; }

}
