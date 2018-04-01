# New Common Windows configuration file.
#
$ErrorActionPreference = "Stop"

. C:\Packer\Scripts\windows-env.ps1

# Enable Bootlog
Write-Output "Enable Bootlog"
cmd /c "bcdedit /set {current} bootlog yes"

# Set the Security Policies
Write-Output "Setting Low Security Password Policies"
secedit /configure /db secedit.sdb /cfg $PackerConfig\Low-SecurityPasswordPolicy.inf /quiet

# Add Firewall rules - these may be moved to Puppet at a later stage.
Write-Output "Enable permissive firewall rules"
netsh advfirewall firewall add rule name="All Incoming" dir=in action=allow enable=yes interfacetype=any profile=any localip=any remoteip=any
netsh advfirewall firewall add rule name="All Outgoing" dir=out action=allow enable=yes interfacetype=any profile=any localip=any remoteip=any
 
# Re-Enable AutoAdminLogon
autologon -AcceptEula Administrator . PackerAdmin

# End
