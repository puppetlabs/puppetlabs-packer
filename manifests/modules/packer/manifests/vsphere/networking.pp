class packer::vsphere::networking {
  if $::operatingsystemrelease in ['15.10', '16.04'] {
    debnet::iface::loopback { 'lo': }
    debnet::iface::dhcp { 'ens32': }
  }
}
