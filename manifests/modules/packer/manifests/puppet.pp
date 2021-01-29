# == Class: packer::puppet
#
# A define that manages puppet
#
class packer::puppet {
  file { '/etc/profile.d/append-puppetlabs-path.sh':
    mode    => '0644',
    content => 'PATH=$PATH:/opt/puppetlabs/bin',
  }
}
