# Set the "License Accepted" registry key for sysinternals tools.
# It is also intended to actually install the tools in the module.
class windows_template::apps::sysinternals()
{
  # Placeholder class to install and configure sysinternals apps.
  # Initially set the registry keys for them.

  $regkeys = ['Process Explorer',
              'Process Monitor',
              'PsExec',
              'PsFile',
              'PsGetSid',
              'PsInfo',
              'PsKill',
              'PsList',
              'PsLoggedOn',
              'PsLogList',
              'PsPasswd',
              'PsService',
              'PsShutdown',
              'PsSuspend',
              'PsTools' ]

  $regkeys.each | String $regkey | {
    registry::value { "Sysinternals_EULA_${regkey}":
      key   => "HKLM\\DEFUSER\\Software\\Sysinternals\\${regkey}",
      value => 'EulaAccepted',
      data  => 1,
      type  => 'dword',
    }
  }
}
