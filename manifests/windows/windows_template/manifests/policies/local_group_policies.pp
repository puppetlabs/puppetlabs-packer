# Class to setup local_group_policies for the packer/windows builds
#
class windows_template::policies::local_group_policies ()
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

    windows_group_policy::local::machine { 'PowerShellExecutionPolicyUnrestricted':
        key    => 'Software\Policies\Microsoft\Windows\PowerShell',
        value  => 'ExecutionPolicy',
        data   => 'Unrestricted',
        type   => 'REG_SZ',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::machine { 'PowerShellExecutionPolicyEnableScripts':
        key    => 'Software\Policies\Microsoft\Windows\PowerShell',
        value  => 'EnableScripts',
        data   => 1,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    windows_group_policy::local::machine { 'DisableServerManagerAtLogon2012':
        key    => 'Software\Policies\Microsoft\Windows\Server\ServerManager',
        value  => 'DoNotOpenAtLogon',
        data   => 1,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::machine { 'DisableServerManagerAtLogon2008':
        key    => 'Software\Policies\Microsoft\Windows\Server\InitialConfigurationTasks',
        value  => 'DoNotOpenAtLogon',
        data   => 1,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    windows_group_policy::local::machine { 'DisableShutdownTracker1':
        key    => 'Software\Policies\Microsoft\Windows NT\Reliability',
        value  => 'ShutdownReasonOn',
        data   => 0,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::machine { 'DisableShutdownTracker2':
        key    => 'Software\Policies\Microsoft\Windows NT\Reliability',
        value  => 'ShutdownReasonUI',
        data   => 0,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    windows_group_policy::local::machine { 'DisableWER':
        key    => 'Software\Policies\Microsoft\Windows\Windows Error Reporting',
        value  => 'Disabled',
        data   => 1,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    windows_group_policy::local::machine { 'DisableSystemRestore':
        key    => 'SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore',
        value  => 'DisableSR',
        data   => 1,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    windows_group_policy::local::user { 'DisableScreenSaver':
        key    => 'SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop',
        value  => 'ScreenSaveActive',
        data   => 0,
        type   => 'REG_SZ',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }

    windows_group_policy::local::user { 'SetClassicDesktop':
        key    => 'SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System',
        value  => 'SetVisualStyle',
        data   => '',
        type   => 'REG_SZ',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::user { 'SetRunOnStartMenu':
        key    => 'Software\Microsoft\Windows\CurrentVersion\Policies\Explore',
        value  => 'ForceRunOnStartMenu',
        data   => 1,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::user { 'SetNoMusic':
        key    => 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        value  => 'NoStartMenuMyMusic',
        data   => 1,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::user { 'SetNoPictures':
        key    => 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        value  => 'NoSMMyPictures',
        data   => 1,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::user { 'ControlPanelAllItems':
        key    => 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        value  => 'ForceClassicControlPanel',
        data   => 1,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    # Settings to control notification area - some of these were attempted in the HKCU settings
    # but are better defined as policy settings (e.g. show all systray notifications)
    windows_group_policy::local::user { 'VolumeControlIcon':
        key    => 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        value  => 'NoAutoTrayNotify',
        data   => 1,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::user { 'ValueHideSCAVolume':
        key    => 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        value  => 'HideSCAVolume',
        data   => 1,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::user { 'NoPinningStoreToTaskbar':
        key    => 'Software\Policies\Microsoft\Windows\Explorer',
        value  => 'NoPinningStoreToTaskbar',
        data   => 1,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
    windows_group_policy::local::user { 'NoShowWindowsStoreAppsOnTaskbar':
        key    => 'Software\Policies\Microsoft\Windows\Explorer',
        value  => 'ShowWindowsStoreAppsOnTaskbar',
        data   => 2,
        type   => 'REG_DWORD',
        notify => Windows_group_policy::Gpupdate['GPUpdate'],
    }
 
    # TODO Update Start Menu 2008 only

    # Disable Windows Update
    windows_group_policy::local::machine { 'DisableWindowsUpdate':
        key    => 'Software\Policies\Microsoft\Windows\WindowsUpdate\AU',
        value  => 'NoAutoUpdate',
        data   => 1,
        type   => 'REG_DWORD',
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
}
