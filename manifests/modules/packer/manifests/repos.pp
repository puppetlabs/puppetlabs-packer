# warapper class to select which repos to install
# this way we can run this class on ots own - needed by docker
class packer::repos {

  if ($::redhat_os_repo or $::redhat_optional_repo or $::redhat_extra_repo) and
  ($::redhat_os_repo != '' or $::redhat_optional_repo != '' or $::redhat_extra_repo != '') {
    include packer::repos::community
  } else {
    include packer::repos::repos
  }
}

