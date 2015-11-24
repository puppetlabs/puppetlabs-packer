class packer::vsphere::repos inherits packer::vsphere::params {
 
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
}
