# Setup the boot configuration
#
class windows_template::bootcfg::bootcfg()
{
  # Get active scheme and return 1 if it doesn't match expected value
  # The check needs to consider no bootlog setting and boolog=no
  $bcd_check = @(BCD_CHECK)
      $bootlogval = bcdedit /enum "{current}" | select-string  "^bootlog" -Context 0,0
      if ($bootlogval.count -eq 0) {Exit 1}
      if ($bootlogval -notmatch "Yes") {Exit 1}
      Exit 0
      | BCD_CHECK

  exec { 'Enable Bootlog':
    command   => 'bcdedit /set "{current}" bootlog yes',
    unless    => $bcd_check,
    provider  => powershell,
    logoutput => true,
  }
}
