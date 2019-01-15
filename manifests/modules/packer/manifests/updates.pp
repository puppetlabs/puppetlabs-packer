class packer::updates {

  $linux_pkgs = [
    'bash',
    'openssl',
  ]

  $debian_pkgs = [
    'libc6',
    'openssh-client',
  ]

  # Updating the EL 6.8 kernel causes a kernel panic on bootup in
  # vCenter 5.5, so it is not included here. Remove this workaround
  # when vCenter gets updated.
  $redhat6_pkgs = [
    'glibc',
    'openssh',
  ]

  $redhat_pkgs = [
    'glibc',
    'openssh',
    'kernel',
  ]

  $suse_pkgs = [
    'glibc',
    'openssh',
    'kernel',
  ]

  $solaris_pkgs = [
    'openssh',
    'kernel',
  ]

  if $::osfamily == 'Debian' {
    $pkgs_to_update = $linux_pkgs + $debian_pkgs
  } elsif $::osfamily == 'Redhat' and $::operatingsystemmajrelease == '6' {
    $pkgs_to_update = $linux_pkgs + $redhat6_pkgs
  } elsif $::osfamily == 'Redhat' {
    $pkgs_to_update = $linux_pkgs + $redhat_pkgs
  } elsif $::osfamily == 'Suse' {
    $pkgs_to_update = $linux_pkgs + $suse_pkgs
  } elsif $::osfamily == 'Solaris'{
    $pkgs_to_update = $linux_pkgs + $solaris_pkgs
  }
  # Macos does not install any of the packages
  if $::osfamily != 'Darwin' {
    package { $pkgs_to_update: ensure => latest; }
  }
  if $::osfamily == 'Suse' {
    file { '/etc/zypp/locks':
      ensure => absent
    }
  }
}
