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
    $base_url = $::operatingsystemmajrelease ? {
      '7' => "${repo_mirror}/rpm-rhel/7.2/${::architecture}",
      '6' => "${repo_mirror}/rpm-rhel/6.8/${::architecture}",
      '5' => "${os_mirror}/rhel50server-${::architecture}/RPMS.all"
    }

    yumrepo { "localmirror-everything":
      descr    => "localmirror-everything",
      baseurl  => "${base_url}",
      gpgcheck => "1",
      gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
    }

  }

}
