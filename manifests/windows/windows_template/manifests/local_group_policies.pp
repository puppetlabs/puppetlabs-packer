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

    # TODO Apply super-insecure password policy Security Template
    #Set the policy "Enforce password history" to "0".
    #Set the policy "Maximum password age" to "0".
    #Set the policy "Minimum password age" to "0".
    #Set the policy "Minimum password length" to "0".
    #Disable the policy "Password must meet complexity requirements".
    #Disable the policy "Store passwords using reversible encryption".

    # TODO Apply High Performance Power Management

    windows_group_policy::local::machine { 'DisableSystemRestore':
        key   => 'SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore',
        value => 'DisableSR',
        data  => 1,
        type  => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    # TODO Change the Desktop Settings to "Classic" and Enable Best Performance <-- Use Boxstarter?

    windows_group_policy::local::user { 'DisableScreenSaver':
        key   => 'SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop',
        value => 'ScreenSaveActive',
        data  => 0,
        type  => 'REG_SZ',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }


    # TODO Update Start Menu 2008 only

    # TODO Modify Notification Icon Tray

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
        type  => 'dword'
    }

    # TODO up to Set IE Home Page to "Blank"
}
