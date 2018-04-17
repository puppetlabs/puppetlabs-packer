# For platforms that come up without any configured software repos
# (e.g, RHEL), this class is used to configure repos pointing to
# our internal mirrors so that packages can be installed by other
# puppet classes (mainly vmtools.pp).
#
# TODO: Consolidate this and the vsphere repos manifest into a single
# module, which can be conditionally included in base.pp for targeted
# platforms and for all cases in vsphere.pp.
class packer::repos {

  if $::operatingsystem == 'RedHat' {

    $repo_mirror = 'https://artifactory.delivery.puppetlabs.net/artifactory'
    $os_mirror   = 'http://osmirror.delivery.puppetlabs.net'
    $gpgkey      = 'RPM-GPG-KEY-redhat-release'

    resources { 'yumrepo':
      purge => true,
    }

    # We don't have consistent mirror urls between RedHat versions:
    # TODO: RHEL 5 needs further refactoring
    $base_url = $::operatingsystemmajrelease ? {
      '7' => "${repo_mirror}/rpm__remote_rhel-72",
      '6' => "${repo_mirror}/rpm__remote_rhel-68-${::architecture}",
      '5' => "${os_mirror}/rhel50server-${::architecture}/RPMS.all"
    }

    yumrepo { "localmirror-os":
      descr    => "localmirror-os",
      baseurl  => "${base_url}/os",
      gpgcheck => "1",
      gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
    }

    yumrepo { "localmirror-optional":
      descr    => "localmirror-optional",
      baseurl  => "${base_url}/optional",
      gpgcheck => "1",
      gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
    }

    yumrepo { "localmirror-extras":
      descr    => "localmirror-extras",
      baseurl  => "${base_url}/extras",
      gpgcheck => "1",
      gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
    }

    # We add the lb (load balancer) repo for redhat-6-x86_64 which is
    # used in puppet modules testing
    if $::operatingsystemmajrelease == "6" and $::architecture == "x86_64" {
      yumrepo { "localmirror-lb":
        descr    => "localmirror-lb",
        baseurl  => "${base_url}/lb",
        gpgcheck => "1",
        gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
      }
    }
  }

}
