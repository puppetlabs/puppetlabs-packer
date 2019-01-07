# for a GPO update.
define windows_group_policy::gpupdate(
  Optional[Pattern[/^(All|Machine|User)$/]] $target = 'All',
  Optional[Boolean] $force                          = true,
  Optional[Boolean] $logoutput                      = false,
  Optional[Integer] $timeout                        = 30,
)
{
  # TODO Support not forcing
  # TODO Support different target types
  # TODO watch out of for prompts.  Need to pipe in 'N'
  # TODO Need to figure out how to do RefreshOnly stuff

  exec { "GPO-GPUPDATE-$name":
    command     => "& cmd /c gpupdate /force /Wait:$timeout",
    provider    => powershell,
    logoutput   => $logoutput,
    timeout     => $timeout,
    refreshonly => true,
  }
}
