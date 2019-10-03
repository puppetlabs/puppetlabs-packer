class windows_template::registry::machine ()
{

    registry::value { 'DebugPolicies':
        key   => 'HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon',
        value => 'UserEnvDebugLevel',
        data  => 196610,
        type  => 'dword'
    }

    # Windows Error Reporting
    registry::value { 'UserModeCrashDumpFolder':
        key   => 'HKLM\\SOFTWARE\\Microsoft\\Windows\\Windows Error Reporting\\LocalDumps',
        value => 'DumpFolder',
        data  => 'C:\\crash_dumps',
        type  => 'expand'
    }
    registry::value { 'UserModeCrashDumpCount':
        key   => 'HKLM\\SOFTWARE\\Microsoft\\Windows\\Windows Error Reporting\\LocalDumps',
        value => 'DumpCount',
        data  => 10,
        type  => 'dword'
    }
    registry::value { 'UserModeCrashDumpType':
        key   => 'HKLM\\SOFTWARE\\Microsoft\\Windows\\Windows Error Reporting\\LocalDumps',
        value => 'DumpType',
        data  => 2,
        type  => 'dword'
    }
    file { 'c:/crash_dumps':
      ensure => 'directory',
      mode   => '0750',
      owner  => $::administrator_sid,
      group  => $::administrator_grp_sid
    }

    # Disable IE ESC for admins
    registry::value { 'DisableIEESCForAdmins':
        key   => 'HKLM\\SOFTWARE\\Microsoft\\Active Setup\\Installed Components\\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}',
        value => 'IsInstalled',
        data  => 0,
        type  => 'dword'
    }
    # Disable IE ESC for non-admins
    registry::value { 'DisableIEESCForNonAdmins':
        key   => 'HKLM\\SOFTWARE\\Microsoft\\Active Setup\\Installed Components\\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}',
        value => 'IsInstalled',
        data  => 0,
        type  => 'dword',
    }

    # Disable prompt for network search - key just has to exist
    registry_key { 'HKLM\System\CurrentControlSet\Control\Network\NewNetworkWindowOff':
        ensure => present,
    }

    # Disable UAC (Moved from boxstarter script)
    registry::value { 'DisableUAC':
        key   => 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System',
        value => 'EnableLUA',
        data  => 0,
        type  => 'dword',
    }
    # Ensure Install MSI As Admin is NOT Disabled.
    registry::value { 'AdminInstallMSI':
        key   => 'HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\Installer',
        value => 'DisableMSI',
        data  => 0,
        type  => 'dword',
    }

    # Set the following BGInfo Variables using lookups from hiera build data.
    registry::value { 'VMPOOLER_Build_Date':
        key   => 'HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment',
        value => 'VMPOOLER_Build_Date',
        data  => lookup('packer.build_date'),
        type  => 'string'
    }
    registry::value { 'VMPOOLER_Packer_SHA':
        key   => 'HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment',
        value => 'VMPOOLER_Packer_SHA',
        data  => lookup('packer.packer_sha'),
        type  => 'string'
    }
    registry::value { 'VMPOOLER_Packer_Template':
        key   => 'HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment',
        value => 'VMPOOLER_Packer_Template',
        data  => lookup('packer.template_name'),
        type  => 'string'
    }
    registry::value { 'VMPOOLER_Packer_Template_Type':
        key   => 'HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment',
        value => 'VMPOOLER_Packer_Template_Type',
        data  => lookup('packer.template_type'),
        type  => 'string'
    }

    ##### SPECIAL
    # ****** Core OS Settings only
    # And a special for Windows Core ServerAdminUI
    # The following is a hack based on the settings on the current live vmpooler Core image to get the RunOnce arming
    # operations to work, even though stricly speaking RunOnce is a function of explorer.exe and therefore should not
    # be supported on a Windows Core Installation.
    # Ticket https://tickets.puppetlabs.com/browse/IMAGES-577 has been raised for follow on investigation and work.
    # Follow on investigation showed that this "hack" is also needed to allow the "FirstLogonCommands" run in the
    # Sysprep Autounattend, so keeping the key in place even though we have moved to scheduled tasks for the startup
    # script.
    #
    if ( $::windows_install_option == 'Core' ) {
        registry::value { 'WinCoreLogon':
          key   => 'HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon',
          value => 'Shell',
          data  => 'explorer.exe',
          type  => 'string',

        }
    }

    if ($::operatingsystemrelease == '2008R2') {
      # WMF5 on 2008R2 causes an issue with sysprep, so set this registry key
      # https://social.technet.microsoft.com/Forums/en-US/a37d2158-1b8b-412e-ad49-02fe0ba573c2/sysprep-fails-on-windows-2008-r2-after-installing-windows-management-framework-50?forum=mdt
      registry::value { 'WMFStreamProvider':
          key   => 'HKLM\\SOFTWARE\\Microsoft\\Windows\\StreamProvider',
          value => 'LastFullPayloadTime',
          data  => 0,
          type  => 'dword'
      }
    }
}
