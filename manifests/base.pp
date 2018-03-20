include packer::repos
include packer::updates
include packer::sshd
include packer::networking

unless $::provisioner in [ 'ec2', 'libvirt', 'virtualbox', 'docker' ] {
  include packer::vmtools
}
