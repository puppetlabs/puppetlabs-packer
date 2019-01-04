define windows_group_policy::gpupdate(
  Pattern[/^(All|Machine|User)$/] $target = 'All',
  Boolean $force = true,
  Boolean $logoutput = false,
  Integer $timeout = 30,
)
{

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
