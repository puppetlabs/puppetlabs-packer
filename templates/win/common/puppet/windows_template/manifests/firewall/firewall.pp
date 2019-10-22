# Set the firewall entries.
class windows_template::firewall::firewall()
{
  # Have tried using the geoffwilliams/windows_firewall module but have have had too many issues.
  # So resorting to simple execs here with a workaround for Win-2008r2.

  if (($::kernelmajversion == '6.0') or ($::kernelmajversion == '6.1')) {

    # This is a very quick and nasty script to handle the command for Win-2008/2008r2/7
    # by using a "touch file" to mark the action as completed.
    # These operating systems are soon to be removed, so its not worth spending any more
    # effort working on this.

    $fw_action = @(FWNETSH_ACTION)
        Try {
          netsh advfirewall firewall add rule name="All Incoming" dir=in action=allow enable=yes interfacetype=any profile=any localip=any remoteip=any
          netsh advfirewall firewall add rule name="All Outgoing" dir=out action=allow enable=yes interfacetype=any profile=any localip=any remoteip=any
          Write-Output $null > C:\Packer\Logs\FireWallRules.Installed
        } Catch {
          Exit 1
        }
        | FWNETSH_ACTION
  } else {

    # Using New-NetFireWallRule cmdlets available on win-2012+ operating systems.

    $fw_action = @(FWPS_ACTION)
        Try {
          Remove-NetFireWallRule -DisplayName "All Incoming" -ErrorAction SilentlyContinue
          New-NetFirewallRule -DisplayName "All Incoming" -Enabled True -Profile Any -Direction Inbound -InterfaceType Any -Action Allow -Protocol TCP -LocalPort Any -LocalAddress Any -RemoteAddress Any
          Remove-NetFireWallRule -DisplayName "All Outgoing" -ErrorAction SilentlyContinue
          New-NetFirewallRule -DisplayName "All Outgoing" -Enabled True -Profile Any -Direction Outbound -InterfaceType Any -Action Allow -Protocol TCP -LocalPort Any -LocalAddress Any -RemoteAddress Any
          Write-Output $null > C:\Packer\Logs\FireWallRules.Installed
        } Catch {
          Exit 1
        }
        | FWPS_ACTION
  }

  exec { 'Enable Firewall Rules':
    command   => $fw_action,
    unless    => 'if (-Not (Test-Path C:\Packer\Logs\FireWallRules.Installed) ) {Exit 1}',
    provider  => powershell,
    logoutput => true,
  }
}
