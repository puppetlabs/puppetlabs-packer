# New Common Windows configuration file.
#

. C:\Packer\Scripts\windows-env.ps1

# Enable Bootlog
Write-Output "Enable Bootlog"
cmd /c "bcdedit /set {current} bootlog yes"

# Set the Security Policies
Write-Output "Setting Low Security Password Policies"
secedit /configure /db secedit.sdb /cfg $PackerConfig\Low-SecurityPasswordPolicy.inf /quiet

# Re-Enable AutoAdminLogon
autologon -AcceptEula Administrator . PackerAdmin

# End
