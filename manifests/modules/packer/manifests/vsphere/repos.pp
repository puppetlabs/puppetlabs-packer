# == Class: packer::repos
#
# A define that manages repos
#
class packer::vsphere::repos(
  Optional[String] $periodic_file = $packer::vsphere::params::periodic_file,
  Optional[String] $repo_mirror = $packer::vsphere::params::repo_mirror,
  Optional[String] $repo_name = $packer::vsphere::params::repo_name,
  Optional[String] $updates_release = $packer::vsphere::params::updates_release,
  Optional[String] $repo_list = $packer::vsphere::params::repo_list,
  Optional[String] $gpgkey = $packer::vsphere::params::gpgkey,
  Optional[String] $security_repo_name = $packer::vsphere::params::security_repo_name,
  Optional[String] $security_release = $packer::vsphere::params::security_release,
  Optional[String] $os_mirror = $packer::vsphere::params::os_mirror,
  Optional[String] $loweros = $packer::vsphere::params::loweros
) inherits packer::vsphere::params {

  case $facts['osfamily'] {

    debian: {
      file { $periodic_file:
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => 'puppet:///modules/packer/vsphere/periodic',
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

      apt::source { $facts['lsbdistcodename']:
        release  => $facts['lsbdistcodename'],
        location => "${repo_mirror}/${repo_name}",
        repos    => $repo_list,
        include  => {
          'src' => true,
          'deb' => true,
        },
      }

      if $facts['operatingsystem'] == 'Debian' and $facts['operatingsystemmajrelease'] !~  /^(7|8)/ {
        apt::source { "${facts['lsbdistcodename']}-updates":
          release  => $updates_release,
          location => "${repo_mirror}/${repo_name}",
          repos    => $repo_list,
          include  => {
            'src' => true,
            'deb' => true,
          },
        }
      }

      apt::source { "${facts['lsbdistcodename']}-security":
        release  => $security_release,
        location => "${repo_mirror}/${security_repo_name}",
        repos    => $repo_list,
        include  => {
          'src' => true,
          'deb' => true,
        },
      }

      if $facts['operatingsystem'] == 'Ubuntu' and $facts['operatingsystemrelease'] == '16.10' {
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

      # IMAGES-1217, for some reason the rebuild of ubuntu 18.04 was missing bionic-updates
      if $facts['operatingsystem'] == 'Ubuntu' and $facts['operatingsystemrelease'] == '18.04' {
        apt::source { "${facts['lsbdistcodename']}-updates":
          release  => $updates_release,
          location => "${repo_mirror}/${repo_name}",
          repos    => $repo_list,
          include  => {
            'src' => true,
            'deb' => true,
          },
        }
      }
    }

    redhat: {

      resources { 'yumrepo':
        purge => true,
      }

      if $facts['operatingsystem'] == 'RedHat' {
        # We don't have consistent mirror urls between RedHat versions:
        # TODO: RHEL 5 needs further refactoring
        # TODO: Change up RHEL 9 when it's out of beta
        $base_url = $facts['operatingsystemmajrelease'] ? {
          '9' => "${repo_mirror}/rpm__remote_rhel-9-beta-x86_64",
          '8' => "${repo_mirror}/rpm__remote_rhel-8",
          '7' => "${repo_mirror}/rpm__remote_rhel-7",
          '6' => "${repo_mirror}/rpm__remote_rhel-68-${::architecture}",
          '5' => "${os_mirror}/rhel50server-${::architecture}/RPMS.all"
        }
      } else {
        $base_url = $facts['operatingsystem'] ? {
          'Fedora'      => "${repo_mirror}/rpm__remote_fedora/releases/${facts['operatingsystemmajrelease']}/Everything/${facts['architecture']}/os",
          'CentOS'      => "${repo_mirror}/rpm__remote_centos/${facts['operatingsystemmajrelease']}",
          'AlmaLinux'   => "${repo_mirror}/almalinux__remote/${facts['operatingsystemmajrelease']}",
          'Rocky'       => "${repo_mirror}/rocky_linux__remote/${facts['operatingsystemmajrelease']}",
          'Scientific'  => "${repo_mirror}/rpm__remote_scientific/${facts['operatingsystemmajrelease']}/${facts['architecture']}",
          'OracleLinux' => "${os_mirror}/${loweros}-${facts['operatingsystemmajrelease']}-${facts['architecture']}/RPMS.all"
        }
      }

      if $facts['operatingsystem'] == 'Fedora' {
        # For Fedora, we use a combined 'everything' repo:
        yumrepo { 'localmirror-everything':
          descr    => 'localmirror-everything',
          baseurl  => $base_url,
          gpgcheck => '1',
          gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
        }
      }

      # This could be a bit DRYer, but there are enough subtle differences
      # between the url formats and repo names used by the other Redhat-based
      # distros that I prefer to keep this more readable:
      if $facts['operatingsystem'] == 'RedHat' {
        if $facts['operatingsystemmajrelease'] == '9' {
          yumrepo { 'localmirror-baseos':
            descr    => 'localmirror-baseos',
            baseurl  => "${base_url}/baseos/${facts['architecture']}",
            gpgcheck => '1',
            gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta,file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release'
          }
          yumrepo { 'localmirror-appstream':
            descr    => 'localmirror-appstream',
            baseurl  => "${base_url}/appstream/${facts['architecture']}",
            gpgcheck => '1',
            gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta,file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release'
          }
        } elsif $facts['operatingsystemmajrelease'] == '8' {
          yumrepo { 'localmirror-base':
            descr    => 'localmirror-base',
            baseurl  => "${base_url}-base",
            gpgcheck => '1',
            gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta,file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release'
          }

          yumrepo { 'localmirror-appstream':
            descr    => 'localmirror-appstream',
            baseurl  => "${base_url}-appstream",
            gpgcheck => '1',
            gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta,file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release'
          }
        } elsif $facts['operatingsystemmajrelease'] == '5' {
          yumrepo { 'localmirror-os':
            descr    => 'localmirror-os',
            baseurl  => "${base_url}/os",
            gpgcheck => '1',
            gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
          }

          yumrepo { 'localmirror-optional':
            descr    => 'localmirror-optional',
            baseurl  => "${base_url}/optional",
            gpgcheck => '1',
            gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
          }

          yumrepo { 'localmirror-extras':
            descr    => 'localmirror-extras',
            baseurl  => "${base_url}/extras",
            gpgcheck => '1',
            gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
          }
        } else {

          yumrepo { 'localmirror-os':
            descr    => 'localmirror-os',
            baseurl  => "${base_url}-os",
            gpgcheck => '1',
            gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
          }

          yumrepo { 'localmirror-optional':
            descr    => 'localmirror-optional',
            baseurl  => "${base_url}-optional",
            gpgcheck => '1',
            gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
          }

          # since the 'extras' repo isn't bound to a specific version,
          # we need to exclude updates to subscription-manager, otherwise
          # yum update will fail due to unmet dependencies
          #
          # see https://access.redhat.com/solutions/3675971
          if $facts['operatingsystemmajrelease'] == '7' {
            $extras_exclude = 'subscription-manager*'
          } else {
            $extras_exclude = undef
          }

          yumrepo { 'localmirror-extras':
            descr    => 'localmirror-extras',
            baseurl  => "${base_url}-extras",
            exclude  =>  $extras_exclude,
            gpgcheck => '1',
            gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
          }
        }

      }

      if $facts['operatingsystem'] in ['CentOS', 'AlmaLinux', 'Rocky'] {
        if $facts['operatingsystemmajrelease'] == '8' {
          yumrepo { 'localmirror-base':
            descr    => 'localmirror-base',
            baseurl  => "${base_url}/BaseOS/${facts['architecture']}/os",
            gpgcheck => '1',
            gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
          }
          yumrepo { 'localmirror-appstream':
            descr    => 'localmirror-appstream',
            baseurl  => "${base_url}/AppStream/${facts['architecture']}/os",
            gpgcheck => '1',
            gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
          }
          yumrepo { 'localmirror-extras':
            descr    => 'localmirror-extras',
            baseurl  => "${base_url}/extras/${facts['architecture']}/os",
            gpgcheck => '1',
            gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
          }
        } else {
          yumrepo { 'localmirror-os':
            descr    => 'localmirror-os',
            baseurl  => "${base_url}/os/${facts['architecture']}",
            gpgcheck => '1',
            gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
          }
          yumrepo { 'localmirror-updates':
            descr    => 'localmirror-updates',
            baseurl  => "${base_url}/updates/${facts['architecture']}",
            gpgcheck => '1',
            gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
          }
          yumrepo { 'localmirror-extras':
            descr    => 'localmirror-extras',
            baseurl  => "${base_url}/extras/${facts['architecture']}",
            gpgcheck => '1',
            gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
          }
        }
      }

      if $facts['operatingsystem'] == 'Scientific' {
        yumrepo { 'localmirror-os':
          descr    => 'localmirror-os',
          baseurl  => "${base_url}/os",
          gpgcheck => '1',
          gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
        }

        # Scientific Linux does things a bit differently and splits up
        # their updates repo into separate 'fastbugs' (for bug
        # fixes/enhancements) and 'security' (for security issues)
        yumrepo { 'localmirror-updates-fastbugs':
          descr    => 'localmirror-updates-fastbugs',
          baseurl  => "${base_url}/updates/fastbugs",
          gpgcheck => '1',
          gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
        }

        yumrepo { 'localmirror-updates-security':
          descr    => 'localmirror-updates-security',
          baseurl  => "${base_url}/updates/security",
          gpgcheck => '1',
          gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
        }
      }

    }

    suse: {
      # $base_url = $facts['operatingsystemrelease'] ? {
      #   # TODO: Mirror this repo over to artifactory
      #   '15.0'    => 'http://osmirror.delivery.puppetlabs.net/sles-15-gm-x86_64/RPMS.os',
      #   '11.4'    =>  'http://osmirror.delivery.puppetlabs.net/sles-11-sp4-x86_64/RPMS.os',
      #   default => "${repo_mirror}/${loweros}-${facts[os][release][major]}-\
      #   sp${facts[os][release][minor]}-${facts[os][architecture]}/RPMS.os"
        case $facts['operatingsystemrelease'] {
          '11.4': {
            if $facts['architecture'] == 'i386'{
              $base_url = 'http://osmirror.delivery.puppetlabs.net/sles-11-sp4-i386/RPMS.os'
            }
            else {
              $base_url = 'http://osmirror.delivery.puppetlabs.net/sles-11-sp4-x86_64/RPMS.os'
            }
          }
          '15.0': {
            $base_url = 'http://osmirror.delivery.puppetlabs.net/sles-15-gm-x86_64/RPMS.os'
          }
          default: {
            # defaults to sles 12
            $base_url = 'http://osmirror.delivery.puppetlabs.net/sles-12-sp1-x86_64/RPMS.os'
          }
      }
      $gpg_check = $::operatingsystemrelease ? {
        # SLES 15/11 defaults to requiring signed repos, and we generate our
        # own repo from the ISO images, which is unsigned
        '15.0'  => '0',
        '11.4'  => '0',
        default => '1'
      }

      zypprepo { 'localmirror-os':
        descr       => 'localmirror-os',
        enabled     => 1,
        autorefresh => 1,
        baseurl     => $base_url,
        gpgcheck    => $gpg_check,
        gpgkey      => "file:///etc/pki/rpm-gpg/${gpgkey}",
        type        => 'rpm-md'
      }

      if $facts['operatingsystemrelease'] == '15.0' {
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
    fail( "Unsupported platform: ${facts['osfamily']}/${facts['operatingsystem']}" )
    }
  }
}
