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
      # TODO: RHEL 8 is beta atm, we need to update with some local mirros when available
      '8' => "https://downloads.redhat.com/redhat/rhel/rhel-8-beta",
      '7' => "${repo_mirror}/rpm__remote_rhel-72",
      '6' => "${repo_mirror}/rpm__remote_rhel-68-${::architecture}",
      '5' => "${os_mirror}/rhel50server-${::architecture}/RPMS.all"
    }

    if $::operatingsystemmajrelease == "8" {
      yumrepo { "rhel-8-for-x86_64-baseos-beta-rpms":
        descr    => "rhel-8-for-x86_64-baseos-beta-rpms",
        baseurl  => "${base_url}/baseos/${::architecture}",
        gpgcheck => "1",
        gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta,file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release"
      }

      yumrepo { "rhel-8-for-x86_64-appstream-beta-rpms":
        descr    => "rhel-8-for-x86_64-appstream-beta-rpms",
        baseurl  => "${base_url}/appstream/${::architecture}",
        gpgcheck => "1",
        gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta,file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release"
      }
    } elsif $::operatingsystemmajrelease == "5" {
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
   } else {

     yumrepo { "localmirror-os":
       descr    => "localmirror-os",
       baseurl  => "${base_url}-os",
       gpgcheck => "1",
       gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
     }

     yumrepo { "localmirror-optional":
       descr    => "localmirror-optional",
       baseurl  => "${base_url}-optional",
       gpgcheck => "1",
       gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
     }

     yumrepo { "localmirror-extras":
       descr    => "localmirror-extras",
       baseurl  => "${base_url}-extras",
       gpgcheck => "1",
       gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
     }
   }

  }
}
