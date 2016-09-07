class windows_template::chrome()
{
  file { "${chrome_root}\\Application\\master_preferences":
    owner  => 'Administrator',
    group  => 'Administrator',
    mode   => '0775',
    source  => "${modules_path}\\windows_template\\files\\master_preferences",
  }
}
