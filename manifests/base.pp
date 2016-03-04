include packer::updates
include packer::sshd
include packer::networking

unless $::provisioner == 'ec2' {
  include packer::vmtools
}
