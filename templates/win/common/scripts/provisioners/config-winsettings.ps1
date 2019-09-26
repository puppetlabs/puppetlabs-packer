# New Common Windows configuration file.
#

. C:\Packer\Scripts\windows-env.ps1

# Enable Bootlog
Write-Output "Enable Bootlog"
cmd /c "bcdedit /set {current} bootlog yes"

# Re-Enable AutoAdminLogon
autologon -AcceptEula Administrator . PackerAdmin

# End
