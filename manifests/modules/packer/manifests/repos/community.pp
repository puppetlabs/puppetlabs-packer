# For platforms that come up without any configured software repos
# (e.g, RHEL), this class is used to configure repos pointing to
# your internal mirrors so that packages can be installed by other
# puppet classes (mainly vmtools.pp).
#
# We only add yum repo definitions when following facts are set using
# environment variables :
#
# * redhat_os_repo
# * redhat_extra_repo
# * redhat_optional_repo
#
# Other local mirrored repos qre out of scope for packer.
#
class packer::repos::community {

  if $::operatingsystem == 'RedHat' {

    $gpgkey      = 'RPM-GPG-KEY-redhat-release'

    resources { 'yumrepo':
      purge => true,
    }

    if $::redhat_os_repo and $::redhat_os_repo != '' {
      yumrepo { "localmirror-os":
        descr    => "localmirror-os",
        baseurl  => $::redhat_os_repo,
        gpgcheck => "1",
        gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
      }
    }

    if $::redhat_optional_repo and $::redhat_optional_repo != '' {
      yumrepo { "localmirror-optional":
        descr    => "localmirror-optional",
        baseurl  => $::redhat_optional_repo,
        gpgcheck => "1",
        gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
      }
    }

    if $::redhat_extra_repo and $::redhat_extra_repo != '' {
      yumrepo { "localmirror-extras":
        descr    => "localmirror-extras",
        baseurl  => $::redhat_extra_repo,
        gpgcheck => "1",
        gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
      }
    }
  }
}
