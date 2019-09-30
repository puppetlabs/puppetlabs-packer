# Downloads and extracts some of the sysinternals suite.
# Set the "License Accepted" registry key for sysinternals tools.
# This is in a seperate class to the sysinternals class to ensure
# all packages are installed before the path and autologon commands
# are executed.
class windows_template::apps::sysinternals_pkgs()
{
  # Placeholder class to install and configure sysinternals apps.
  # Initially set the registry keys for them.

  $sysinternalsdownloadurl = 'https://download.sysinternals.com/files'

  $sysinternalsutilsinstpairs = [ ['ProcessExplorer','procexp.exe'],
                                  ['ProcessMonitor','procmon.exe'],
                                  ['PSTools','psversion.txt'],
                                  ['BGInfo','Bginfo.exe'],
                                  ['AutoLogon','Autologon.exe'] ]

    $sysinternalsutilsinstpairs.each | Array $sysintalsutilinst | {
      $sysinternalszip = $sysintalsutilinst[0]
      $sysinternalsfile = $sysintalsutilinst[1]

      archive { "${::packer_downloads}/${sysinternalszip}.zip" :
        source       => "${sysinternalsdownloadurl}/${sysinternalszip}.zip",
        extract      => true,
        extract_path => $::sysinternals,
        creates      => "${::sysinternals}/${sysinternalsfile}"
      }
  }

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
