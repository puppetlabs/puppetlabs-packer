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
        data   => '10.240.0.10 10.240.1.10',
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

    # Screen out these policies for anything earlier than Win-2012r2
    #
    if ("$::kernelmajversion" == '10.0' ) {
        # Mostly Win-10 policies.
        #  1. Turn off Tile Notifications
        windows_group_policy::local::user { 'NotileApplicationNotification':
            key    => 'Software\Policies\Microsoft\Windows\CurrentVersion\Pushnotifications',
            value  => 'NotileApplicationNotification',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        #  2. Clear Tile Notifications at login
        windows_group_policy::local::user { 'CleartilesOnExit':
            key    => 'Software\Policies\Microsoft\Windows\Explorer',
            value  => 'CleartilesOnExit',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        #  3. Computer Configuration > Administrative Templates > Windows Components > Cloud Content "Turn off Microsoft consumer Experience"
        windows_group_policy::local::machine { 'DisableWindowsConsumerFeatures':
            key    => 'Software\Policies\microsoft\Windows\CloudContent',
            value  => 'DisableWindowsConsumerFeatures',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        #  4. User - Cloud Content urn off the Windows Welcome Experience - Enabled
        windows_group_policy::local::user { 'DisableWindowsSpotlightWindowswelcomeexperience':
            key    => 'Software\Policies\Microsoft\Windows\CloudContent',
            value  => 'DisableWindowsSpotlightWindowswelcomeexperience',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        #  5. User Cloud content Do not suggest Third-party-content
        windows_group_policy::local::user { 'DisablethirdpartySuggestions':
            key    => 'Software\Policies\Microsoft\Windows\CloudContent',
            value  => 'DisablethirdpartySuggestions',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        #  6. Windows components - Prevent the usage of OneDrive for file storage
        windows_group_policy::local::machine { 'DisableFileSyncNGSC':
            key    => 'Software\Policies\Microsoft\Windows\onedrive',
            value  => 'DisableFileSyncNGSC',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        #  7. Microsoft Edge - Configure Start Page About:blank
        windows_group_policy::local::user { 'EdgeProvisionedHomePages':
            key    => 'Software\Policies\microsoft\microsoftedge\Internet Settings',
            value  => 'ProvisionedHomePages',
            data   => 'about:blank',
            type   => 'REG_SZ',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        #  8. Turn off Windows Defender Antivirus
        windows_group_policy::local::machine { 'DisableWindowsDefender':
            key    => 'Software\Policies\Microsoft\Windows Defender',
            value  => 'DisableAntiSpyware',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        #  9. Turn off Desktop Gadgets
        windows_group_policy::local::machine { 'DisableDesktopGadgets':
            key    => 'Software\Microsoft\Windows\CurrentVersion\Policies\Windows\Sidebar',
            value  => 'TurnOffSidebar',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        # 10. Use Solid colour for start background
        windows_group_policy::local::machine { 'UseWindowsSolidColour':
            key    => 'Software\Policies\Microsoft\Windows\DWM',
            value  => 'DisableAccentGradient',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        # 11. Do not allow windows animations
        windows_group_policy::local::machine { 'Disallowanimations':
            key    => 'Software\Policies\Microsoft\Windows\DWM',
            value  => 'Disallowanimations',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        # 12. Turn off Sync Updates
        windows_group_policy::local::machine { 'DontSyncWindows8AppSettings':
            key    => 'Software\Policies\Microsoft\UEV\Agent\Configuration',
            value  => 'DontSyncWindows8AppSettings',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        # 13. Turn off location - Leave
        # 14. Allow Cortana - DISABLE
        windows_group_policy::local::machine { 'AllowCortana':
            key    => 'Software\Policies\Microsoft\Windows\Windows Search',
            value  => 'AllowCortana',
            data   => 0,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        # 15. Turn off Store Application
        windows_group_policy::local::machine { 'DisablestoreApps':
            key    => 'Software\Policies\Microsoft\Windowsstore',
            value  => 'DisablestoreApps',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        # 16. Turn off offer to update to latest version of windows
        windows_group_policy::local::machine { 'DisableOSUpgrade':
            key    => 'Software\Policies\Microsoft\WindowsStore',
            value  => 'DisableOSUpgrade',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        # 17. Remove Games from Start Menu
        windows_group_policy::local::user { 'NoStartMenuMyGames':
            key    => 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer',
            value  => 'NoStartMenuMyGames',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        # 18. Disable Store Completely.
        windows_group_policy::local::user { 'DisableAllStoreApps':
            key    => 'Software\Policies\Microsoft\Windows\WindowsStore',
            value  => 'DisableStoreApps',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        # 19. Remove Store Completely.
        # Note - duplicated in registry at startup to try and get round sysprep issues
        windows_group_policy::local::user { 'RemoveWindowsStore':
            key    => 'Software\Policies\Microsoft\Windows\WindowsStore',
            value  => 'RemoveWindowsStore',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        # 20. Remove the My People Bar.
        windows_group_policy::local::user { 'RemovePeopleBar':
            key    => 'Software\Policies\Microsoft\Windows\Explorer',
            value  => 'HidePeopleBar',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        # 21. Configure the Start Layour
        windows_group_policy::local::user { 'StartLayoutConfigLock':
            key    => 'Software\Policies\Microsoft\Windows\Explorer',
            value  => 'LockedStartLayout',
            data   => 1,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        windows_group_policy::local::user { 'StartLayoutConfig':
            key    => 'Software\Policies\Microsoft\Windows\Explorer',
            value  => 'StartLayoutFile',
            data   => 'C:\\Packer\\Config\\StartMenuLayout.xml',
            type   => 'REG_SZ',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
        # 22. Disable the first logon animation
        windows_group_policy::local::machine { 'DisableFirstLogonAnimation':
            key    => 'Software\Microsoft\Windows\CurrentVersion\Policies\System',
            value  => 'EnableFirstLogonAnimation',
            data   => 0,
            type   => 'REG_DWORD',
            notify => Windows_group_policy::Gpupdate['GPUpdate'],
        }
    }
}
