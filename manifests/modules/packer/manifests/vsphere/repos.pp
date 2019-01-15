class packer::vsphere::repos inherits packer::vsphere::params {

  case $::osfamily {

    debian: {

      file { $periodic_file:
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///modules/packer/vsphere/periodic',
      }

      # exec { "apt-update":
      #   command => "/usr/bin/apt-get update"
      # }

      # Apt::Key <| |> -> Exec["apt-update"]
      # Apt::Source <| |> -> Exec["apt-update"]

      Exec['apt_update'] -> Package <| |>

      class { 'apt':
        purge => {
          'sources.list'   => true,
          'sources.list.d' => true,
        },
      }

      apt::source { "$lsbdistcodename":
        release  => $lsbdistcodename,
        location => "$repo_mirror/$repo_name",
        repos    => "$repo_list",
        include  => {
          'src' => true,
          'deb' => true,
        },
      }

      apt::source { "${lsbdistcodename}-updates":
        release  => "$updates_release",
        location => "${repo_mirror}/${repo_name}",
        repos    => "$repo_list",
        include  => {
          'src' => true,
          'deb' => true,
        },
      }

      apt::source { "${lsbdistcodename}-security":
        release  => "$security_release",
        location => "${repo_mirror}/${security_repo_name}",
        repos    => "$repo_list",
        include  => {
          'src' => true,
          'deb' => true,
        },
      }

      if $::operatingsystem == 'Ubuntu' and $::operatingsystemrelease == '16.10' {
        apt::pin { 'apt-puppet-agent':
          packages => 'puppet-agent',
          origin   => 'apt.puppetlabs.com',
          priority => 1001,
        }
        apt::pin { 'builds-puppet-agent':
          packages => 'puppet-agent',
          origin   => 'builds.delivery.puppetlabs.net',
          priority => 1001,
        }
      }
    }

    redhat: {

      resources { 'yumrepo':
        purge => true,
      }

      if $::operatingsystem == 'RedHat' {
        # We don't have consistent mirror urls between RedHat versions:
        # TODO: RHEL 5 needs further refactoring
        $base_url = $::operatingsystemmajrelease ? {
          # TODO: RHEL 8 is beta atm, we need to update with some local mirros when available
          '8' => "https://downloads.redhat.com/redhat/rhel/rhel-8-beta",
          '7' => "${repo_mirror}/rpm-rhel-7-${::architecture}",
          '6' => "${repo_mirror}/rpm__remote_rhel-68-${::architecture}",
          '5' => "${os_mirror}/rhel50server-${::architecture}/RPMS.all"
        }
      } else {
        $base_url = $::operatingsystem ? {
          'Fedora'      => "${repo_mirror}/rpm__remote_fedora/releases/${::operatingsystemmajrelease}/Everything/${::architecture}/os",
          'CentOS'      => "${repo_mirror}/rpm__remote_centos/${::operatingsystemmajrelease}",
          'Scientific'  => "${repo_mirror}/rpm__remote_scientific/${::operatingsystemmajrelease}/${::architecture}",
          'OracleLinux' => "${os_mirror}/${loweros}-${::operatingsystemmajrelease}-${::architecture}/RPMS.all"
        }
      }

      if $::operatingsystem == 'Fedora' {
        # For Fedora, we use a combined 'everything' repo:
        yumrepo { "localmirror-everything":
          descr    => "localmirror-everything",
          baseurl  => "${base_url}",
          gpgcheck => "1",
          gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
        }
      }

      # This could be a bit DRYer, but there are enough subtle differences
      # between the url formats and repo names used by the other Redhat-based
      # distros that I prefer to keep this more readable:
      if $::operatingsystem == 'RedHat' {
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
        } elsif $::operatingsystemmajrelease == "7" {
          yumrepo { "localmirror-everything":
            descr    => "localmirror-everything",
            baseurl  => "${base_url}",
            gpgcheck => "1",
            gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
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

          # since the 'extras' repo isn't bound to a specific version,
          # we need to exclude updates to subscription-manager, otherwise
          # yum update will fail due to unmet dependencies
          #
          # see https://access.redhat.com/solutions/3675971
          if $::operatingsystemmajrelease == "7" {
            $extras_exclude = "subscription-manager*"
          } else {
            $extras_exclude = undef
          }

          yumrepo { "localmirror-extras":
            descr    => "localmirror-extras",
            baseurl  => "${base_url}-extras",
            exclude  =>  $extras_exclude,
            gpgcheck => "1",
            gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
          }
        }

      }

      if $::operatingsystem == 'CentOS' {
        yumrepo { "localmirror-os":
          descr    => "localmirror-os",
          baseurl  => "${base_url}/os/${::architecture}",
          gpgcheck => "1",
          gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
        }

        yumrepo { "localmirror-updates":
          descr    => "localmirror-updates",
          baseurl  => "${base_url}/updates/${::architecture}",
          gpgcheck => "1",
          gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
        }

        yumrepo { "localmirror-extras":
          descr    => "localmirror-extras",
          baseurl  => "${base_url}/extras/${::architecture}",
          gpgcheck => "1",
          gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
        }
      }

      if $::operatingsystem == 'Scientific' {
        yumrepo { "localmirror-os":
          descr    => "localmirror-os",
          baseurl  => "${base_url}/os",
          gpgcheck => "1",
          gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
        }

        # Scientific Linux does things a bit differently and splits up
        # their updates repo into separate 'fastbugs' (for bug
        # fixes/enhancements) and 'security' (for security issues)
        yumrepo { "localmirror-updates-fastbugs":
          descr    => "localmirror-updates-fastbugs",
          baseurl  => "${base_url}/updates/fastbugs",
          gpgcheck => "1",
          gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
        }

        yumrepo { "localmirror-updates-security":
          descr    => "localmirror-updates-security",
          baseurl  => "${base_url}/updates/security",
          gpgcheck => "1",
          gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
        }
      }

    }

    suse: {
      $base_url = $::operatingsystemrelease ? {
        # TODO: Mirror this repo over to artifactory
        '15.0'    => "http://osmirror.delivery.puppetlabs.net/sles-15-gm-x86_64/RPMS.os",
        default => "${repo_mirror}/${loweros}-${facts[os][release][major]}-sp${facts[os][release][minor]}-${facts[os][architecture]}/RPMS.os"
      }

      $gpg_check = $::operatingsystemrelease ? {
        # SLES 15 defaults to requiring signed repos, and we generate our
        # own repo from the ISO images, which is unsigned
        '15.0' => "0",
        default => "1"
      }

      zypprepo { "localmirror-os":
        descr       => "localmirror-os",
        enabled     => 1,
        autorefresh => 1,
        baseurl     => "${base_url}",
        gpgcheck    => "${gpg_check}",
        gpgkey      => "file:///etc/pki/rpm-gpg/${gpgkey}",
        type        => 'rpm-md'
      }

      if $::operatingsystemrelease == "15.0" {
        exec { 'Un-register SLES from SUSEConnect':
          command => '/usr/sbin/SUSEConnect --cleanup',
          path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin', ]
        }
      }
    }

    solaris: {
      # Solaris repo: http://solaris-11-reposync.delivery.puppetlabs.net:81
      # Added Solaris case so it wont execute default one & added solaris repo link in case we need it in the future.
    }

    darwin: {
      # Added darwin case so it wont execute default one
    }

  default: {
    fail( "Unsupported platform: ${::osfamily}/${::operatingsystem}" )
    }
  }
}
