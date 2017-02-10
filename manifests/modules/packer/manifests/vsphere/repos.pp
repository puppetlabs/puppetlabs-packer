class packer::vsphere::repos inherits packer::vsphere::params {

  case $::osfamily {

    debian: {

      exec { "apt-update":
        command => "/usr/bin/apt-get update"
      }

      Apt::Key <| |> -> Exec["apt-update"]
      Apt::Source <| |> -> Exec["apt-update"]

      Exec["apt-update"] -> Package <| |>

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

      yumrepo { "localmirror-os":
        descr    => "localmirror-os",
        baseurl  => "${repo_mirror}/${loweros}-${::operatingsystemmajrelease}-${::architecture}/RPMS.os",
        gpgcheck => "1",
        gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
      }
      yumrepo { "localmirror-updates":
        descr    => "localmirror-updates",
        baseurl  => "${repo_mirror}/${loweros}-${::operatingsystemmajrelease}-${::architecture}/RPMS.updates",
        gpgcheck => "1",
        gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
      }
      
      if $::operatingsystem == 'Fedora' {
        yumrepo { "localmirror-everything":
          descr    => "localmirror-everything",
          baseurl  => "${repo_mirror}/${loweros}-${::operatingsystemmajrelease}-${::architecture}/RPMS.everything",
          gpgcheck => "1",
          gpgkey   => "file:///etc/pki/rpm-gpg/${gpgkey}"
        }
      }
   }  

   default: {
     fail( "Unsupported platform: ${::osfamily}/${::operatingsystem}" )
   }
  }
}
