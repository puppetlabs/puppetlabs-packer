# Configures the Chrome start page.
# It is intended to use this to install Chrome
class windows_template::apps::chrome()
{
  file { "${::chrome_root}\\Application\\master_preferences":
    owner  => "${::administrator_sid}",
    group  => "${::administrator_grp_sid}",
    mode   => '0775',
    source => "${::modules_path}\\windows_template\\files\\master_preferences",
  }

  # Disable Google Update Services to prevent pending reboot requests (except win-2008)
  service { 'gupdate':
    ensure => 'stopped',
    enable => false,
  }
  service { 'gupdatem':
    ensure => 'stopped',
    enable => false,
  }
}
