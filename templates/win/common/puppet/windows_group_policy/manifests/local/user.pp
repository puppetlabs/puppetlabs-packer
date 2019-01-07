# Update a local user policy 
define windows_group_policy::local::user(
  Pattern[/^(present|absent)$/] $ensure = 'present',
  String $key                           = '',
  String $value                         = '',
  Pattern[/^(REG_SZ|REG_DWORD)$/] $type = 'REG_SZ',
  Variant[String,Integer] $data         = '',
  Optional[Boolean] $logoutput          = false,
)
{
  $policy_type = 'User'

  if $ensure in ['present'] {
    exec { "GPO-Local-User-$name":
      command   => template('windows_group_policy/script_header.ps1',
                            'windows_group_policy/PolFileEditor.ps1',
                            'windows_group_policy/local_gpo.ps1',
                            'windows_group_policy/command-set.ps1'),
      unless    => template('windows_group_policy/script_header.ps1',
                            'windows_group_policy/PolFileEditor.ps1',
                            'windows_group_policy/local_gpo.ps1',
                            'windows_group_policy/command-unless.ps1'),
      provider  => powershell,
      logoutput => $logoutput,
    }
  } else {
    # Do stuff to remove it
    Notify{ '***** Removing GPOs is NOT IMPLEMENTED': }
  }
}
