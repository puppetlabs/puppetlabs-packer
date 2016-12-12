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
    $pkgs_to_update = $linux_pkgs + $debian_pkgs
  } elsif $::osfamily == 'Redhat' {
    $pkgs_to_update = $linux_pkgs + $redhat_pkgs
  }

  package { $pkgs_to_update: ensure => latest; }

  if $::operatingsystem == 'Ubuntu' {
    file { '/etc/apt/apt.conf.d/10disable-periodic':
      content => 'APT::Periodic::Enable \"0\";'
    }
  }
}
