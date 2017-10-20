# Set the firewall entries.
# Holding on actually using this module to figure out if it does what we need.
class windows_template::firewall::firewall()
{

#  Note - these rules aren't actually in place yet - the config-winsettings.ps1 script is still used.
  windows_firewall::exception { 'All Incoming':
    ensure       => present,
    direction    => 'in',
    action       => 'Allow',
    enabled      => 'yes',
    protocol     => 'TCP',
    local_port   => '5985',
    remote_port  => 'any',
    display_name => 'All Incoming',
    description  => 'Allow all incoming',
  }

  windows_firewall::exception { 'All Outgoing':
    ensure       => present,
    direction    => 'out',
    action       => 'Allow',
    enabled      => 'yes',
    protocol     => 'TCP',
    local_port   => 'any',
    remote_port  => 'any',
    display_name => 'All Outgoing',
    description  => 'Allow all outgoing',
  }

}
