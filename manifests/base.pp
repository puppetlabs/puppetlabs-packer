include packer::repos
include packer::updates
include packer::sshd
include packer::networking

# Building on vCenter means we need to set up the vmtools ourselves
unless $::provisioner in ['ec2', 'libvirt'] or $::packer_build_name == 'vcenter-iso' {
  include packer::vmtools
}
