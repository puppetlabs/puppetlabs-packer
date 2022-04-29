# == Class: packer::updates
#
# A define that manages puppet modules
#
class packer::vsphere::updates {
  $linux_pkgs = [
    'bash',
    'openssl',
  ]

  $debian_pkgs = [
    'libc6',
    'openssh-client',
    'apt',
  ]

  $redhat_pkgs = [
    #  'kernel',
    'glibc',
    'openssh',
  ]

  $suse_pkgs = [
    'glibc',
    'kernel',
  ]

  $solaris_pkgs = [
    'openssh',
    'kernel',
  ]

  if $facts['osfamily'] == 'Debian' {
    $pkgs_to_update = $linux_pkgs + $debian_pkgs
  } elsif $::osfamily == 'Redhat' {
    $pkgs_to_update = $linux_pkgs + $redhat_pkgs
  } elsif $::osfamily == 'Suse' {
    $pkgs_to_update = $linux_pkgs + $suse_pkgs
  } elsif $::osfamily == 'Solaris'{
    $pkgs_to_update = $linux_pkgs + $solaris_pkgs
  }
  # Macos does not install any of the packages
  if $facts['osfamily'] != 'Darwin' {
    package { $pkgs_to_update: ensure => latest; }
  }
  if $facts['osfamily'] == 'Suse' {
    file { '/etc/zypp/locks':
      ensure => absent
    }
  }
}
