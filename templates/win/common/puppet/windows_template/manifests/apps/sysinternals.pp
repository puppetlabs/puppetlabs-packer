# Downloads and extracts some of the sysinternals suite.
# Set the "License Accepted" registry key for sysinternals tools.
# Sets Path to include the utilities.
class windows_template::apps::sysinternals()
{
  include windows_template::apps::sysinternals_pkgs

  windows_env { "PATH=${::sysinternals}":
    # Update Path to include sysinternals path - this seems to be all thats necessary.
    ensure    => present,
    mergemode => insert,
    require   => Class['windows_template::apps::sysinternals_pkgs'],

  } -> exec { 'Enable AutoLogon':
      #
      # Check to see if AutoLogon is enabled and enable it.
      # (this is check only as the initial unattend should have done this already)
      command   => 'autologon -AcceptEula Administrator . PackerAdmin',
      unless    => 'try {if ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon").AutoAdminLogon -eq 1) {Exit 0} else {Exit 1}} catch {Exit 1}', # lint:ignore:140chars
      provider  => powershell,
      logoutput => true,
  }
}
