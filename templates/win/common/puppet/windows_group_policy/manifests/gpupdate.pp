define windows_group_policy::gpupdate(
  $target = 'All',
  $force = true,
  $logoutput = false,
  $timeout = 30,
)
{
  validate_re($target, '^(All|Machine|User)$', 'target must be one of \'All\', \'Machine\' or \'User\'')

  # TODO Support not forcing
  # TODO Support different target types
  # TODO watch out of for prompts.  Need to pipe in 'N'
  # TODO Need to figure out how to do RefreshOnly stuff

  exec { "GPO-GPUPDATE-$name":
    command => "& cmd /c gpupdate /force /Wait:$timeout",
    provider => powershell,
    logoutput => $logoutput,
    timeout => $timeout,
    refreshonly => true,
  }
}