class packer::vsphere::networking {
  if $::operatingsystemrelease == '15.10' {
    debnet::iface::loopback { 'lo': }
    debnet::iface::dhcp { 'ens32': }
  }
}
