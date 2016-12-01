class windows_template::local_group_policies ()
{
    # Search Group Policies and find their registry information
    # http://gpsearch.azurewebsites.net/

    windows_group_policy::gpupdate { 'GPUpdate':
    }

    windows_group_policy::local::machine_client_side_extensions { "MachineGCE":
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::user_client_side_extensions { "UserGCE":
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    registry::value { 'DebugPolicies':
        key   => 'HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon',
        value => 'UserEnvDebugLevel',
        data  => 196610,
        type  => 'dword'
    }
    windows_group_policy::local::machine { 'PowerShellExecutionPolicyUnrestricted':
        key   => 'Software\Policies\Microsoft\Windows\PowerShell',
        value => 'ExecutionPolicy',
        data  => 'Unrestricted',
        type  => 'REG_SZ',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::machine { 'PowerShellExecutionPolicyEnableScripts':
        key   => 'Software\Policies\Microsoft\Windows\PowerShell',
        value => 'EnableScripts',
        data  => 1,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    windows_group_policy::local::machine { 'DisableServerManagerAtLogon2012':
        key   => 'Software\Policies\Microsoft\Windows\Server\ServerManager',
        value => 'DoNotOpenAtLogon',
        data  => 1,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::machine { 'DisableServerManagerAtLogon2008':
        key   => 'Software\Policies\Microsoft\Windows\Server\InitialConfigurationTasks',
        value => 'DoNotOpenAtLogon',
        data  => 1,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    windows_group_policy::local::machine { 'DisableShutdownTracker1':
        key   => 'Software\Policies\Microsoft\Windows NT\Reliability',
        value => 'ShutdownReasonOn',
        data  => 0,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::machine { 'DisableShutdownTracker2':
        key   => 'Software\Policies\Microsoft\Windows NT\Reliability',
        value => 'ShutdownReasonUI',
        data  => 0,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    windows_group_policy::local::machine { 'DisableWER':
        key   => 'Software\Policies\Microsoft\Windows\Windows Error Reporting',
        value => 'Disabled',
        data  => 1,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    # Windows Error Reporting
    registry::value { 'UserModeCrashDumpFolder':
        key   => 'HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps',
        value => 'DumpFolder',
        data  => 'C:\crash_dumps',
        type  => 'expand'
    }
    registry::value { 'UserModeCrashDumpCount':
        key   => 'HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps',
        value => 'DumpCount',
        data  => 10,
        type  => 'dword'
    }
    registry::value { 'UserModeCrashDumpType':
        key   => 'HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps',
        value => 'DumpType',
        data  => 2,
        type  => 'dword'
    }
    file { 'c:/crash_dumps':
      ensure => 'directory',
      mode   => '0750',
      owner  => 'Administrator',
      group  => 'Administrators'
    }

    windows_group_policy::local::machine { 'DisableSystemRestore':
        key   => 'SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore',
        value => 'DisableSR',
        data  => 1,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    windows_group_policy::local::user { 'DisableScreenSaver':
        key   => 'SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop',
        value => 'ScreenSaveActive',
        data  => 0,
        type  => 'REG_SZ',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    windows_group_policy::local::user { 'SetClassicDesktop':
        key   => 'SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System',
        value => 'SetVisualStyle',
        data  => '',
        type  => 'REG_SZ',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::user { 'SetRunOnStartMenu':
        key   => 'Software\Microsoft\Windows\CurrentVersion\Policies\Explore',
        value => 'ForceRunOnStartMenu',
        data  => 1,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::user { 'SetNoMusic':
        key   => 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        value => 'NoStartMenuMyMusic',
        data  => 1,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::user { 'SetNoPictures':
        key   => 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        value => 'NoSMMyPictures',
        data  => 1,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::user { 'SetNoWindowsStore':
        key   => 'Software\Policies\Microsoft\Windows\Explorer',
        value => 'ShowWindowsStoreAppsOnTaskbar',
        data  => 2,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::user { 'ControlPanelAllItems':
        key   => 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        value => 'ForceClassicControlPanel',
        data  => 1,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    # TODO Update Start Menu 2008 only

    # Power plan and high performance.
    windows_group_policy::local::machine { 'HighPerformancePowerPlan':
        key   => 'Software\Policies\Microsoft\Power\PowerSettings',
        value => 'ActivePowerScheme',
        data  => '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c',
        type  => 'REG_SZ',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    # Turn off the display (plugged in)
    windows_group_policy::local::machine { 'DisableTurnOffDisplayPluggedIn':
        key   => 'Software\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E',
        value => 'ACSettingIndex',
        data  => 0,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    # Turn off the display (on battery)
    windows_group_policy::local::machine { 'DisableTurnOffDisplayOnBattery':
        key   => 'Software\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E',
        value => 'DCSettingIndex',
        data  => 0,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    # Turn off hybrid sleep (on battery)
    windows_group_policy::local::machine { 'DisableHibernationOnBattery':
        key   => 'Software\Policies\Microsoft\Power\PowerSettings\94ac6d29-73ce-41a6-809f-6363ba21b47e',
        value => 'DCSettingIndex',
        data  => 0,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    # Turn off hybrid sleep (plugged in)
    windows_group_policy::local::machine { 'DisableHibernationPluggedIn':
        key   => 'Software\Policies\Microsoft\Power\PowerSettings\94ac6d29-73ce-41a6-809f-6363ba21b47e',
        value => 'ACSettingIndex',
        data  => 0,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    # Disable IE ESC for admins
    registry::value { 'DisableIEESCForAdmins':
        key   => 'HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}',
        value => 'IsInstalled',
        data  => 0,
        type  => 'dword'
    }
    # Disable IE ESC for non-admins
    registry::value { 'DisableIEESCForNonAdmins':
        key   => 'HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}',
        value => 'IsInstalled',
        data  => 0,
        type  => 'dword',
    }

    # Disable prompt for network search - key just has to exist
    registry_key { 'HKLM\System\CurrentControlSet\Control\Network\NewNetworkWindowOff':
        ensure => present,
    }
    # Disable Windows Update
    windows_group_policy::local::machine { 'DisableWindowsUpdate':
        key   => 'Software\Policies\Microsoft\Windows\WindowsUpdate\AU',
        value => 'NoAutoUpdate',
        data  => 1,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    # Configure NTP Time Synchronisation
    # https://technet.microsoft.com/en-us/library/bb490845.aspx?f=255&MSPPError=-2147217396
    windows_group_policy::local::machine { 'W32timeType':
        key    => 'Software\Policies\Microsoft\W32time\Parameters',
        value  => 'Type',
        data   => 'NTP',
        type   => 'REG_SZ',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::machine { 'W32timeNTPServerList':
        key    => 'Software\Policies\Microsoft\W32time\Parameters',
        value  => 'NtpServer',
        data   => 'opdx-net01-prod.ops.puppetlabs.net pdx-net01-prod.ops.puppetlabs.net opdx-net02.service.puppetlabs.net pdx-net02-prod.ops.puppetlabs.net',
        type   => 'REG_SZ',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::machine { 'W32timeNTPClientEnabled':
        key    => 'Software\Policies\Microsoft\W32time\TimeProviders\NtpClient',
        value  => 'Enabled',
        data   => 1,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::machine { 'W32timeNTPClientCrossSiteSyncFlags':
        key    => 'Software\Policies\Microsoft\W32time\TimeProviders\NtpClient',
        value  => 'CrossSiteSyncFlags',
        data   => 2, # All
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::machine { 'W32timeNTPClientResolvePeerBackoffMinutes':
        key    => 'Software\Policies\Microsoft\W32time\TimeProviders\NtpClient',
        value  => 'ResolvePeerBackoffMinutes',
        data   => 15,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::machine { 'W32timeNTPClientResolvePeerBackoffMaxTimes':
        key    => 'Software\Policies\Microsoft\W32time\TimeProviders\NtpClient',
        value  => 'ResolvePeerBackoffMaxTimes',
        data   => 7,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::machine { 'W32timeNTPClientSpecialPollInterval':
        key    => 'Software\Policies\Microsoft\W32time\TimeProviders\NtpClient',
        value  => 'SpecialPollInterval',
        data   => 600, # Poll for time every 10minutes
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::machine { 'W32timeNTPClientEventLogFlags':
        key    => 'Software\Policies\Microsoft\W32time\TimeProviders\NtpClient',
        value  => 'EventLogFlags',
        data   => 3, # Enable full debug log
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    # Set the following BGInfo Variables using facter provided variables from env
    #VMPOOLER_Build_Date=Build-Date
    #VMPOOLER_Packer_SHA=124214215215215235
    #VMPOOLER_Packer_Template=Packer_Template_Name & type
    registry::value { 'VMPOOLER_Build_Date':
        key   => 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
        value => 'VMPOOLER_Build_Date',
        data  => "${build_date}",
        type  => 'string'
    }
    registry::value { 'VMPOOLER_Packer_SHA':
        key   => 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
        value => 'VMPOOLER_Packer_SHA',
        data  => "${packer_sha}",
        type  => 'string'
    }
    registry::value { 'VMPOOLER_Packer_Template':
        key   => 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
        value => 'VMPOOLER_Packer_Template',
        data  => "${packer_template_name}",
        type  => 'string'
    }
    registry::value { 'VMPOOLER_Packer_Template_Type':
        key   => 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
        value => 'VMPOOLER_Packer_Template_Type',
        data  => "${packer_template_type}",
        type  => 'string'
    }

}
