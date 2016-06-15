define windows_group_policy::local::user(
  $ensure    = 'present',
  $key       = '',
  $value     = '',
  $type      = 'REG_SZ',
  $data      = '',
  $logoutput = false,
)
{
  validate_re($ensure, '^(present|absent)$', 'ensure must be one of \'present\' or \'absent\'')
  validate_re($type, '^(REG_SZ|REG_DWORD)$', 'type must be one of \'REG_SZ\' or \'REG_DWORD\'')

  $policy_type = 'User'

  if $ensure in ['present'] {
    exec { "GPO-Local-Machine-$name":
      command => template('windows_group_policy/script_header.ps1',
                          'windows_group_policy/PolFileEditor.ps1',
                          'windows_group_policy/local_gpo.ps1',
                          'windows_group_policy/command-set.ps1'),
      unless => template('windows_group_policy/script_header.ps1',
                         'windows_group_policy/PolFileEditor.ps1',
                         'windows_group_policy/local_gpo.ps1',
                         'windows_group_policy/command-unless.ps1'),
      provider => powershell,
      logoutput => $logoutput,
    }
  } else {
    # Do stuff to remove it
    Notify{ '***** Removing GPOs is NOT IMPLEMENTED': }
  }   
}