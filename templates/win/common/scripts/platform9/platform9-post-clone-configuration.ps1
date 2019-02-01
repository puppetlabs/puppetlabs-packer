# Platform9 Post Clone configuration script
#

. C:\Packer\Scripts\windows-env.ps1

$rundate = date
write-output "Script: platform9-post-clone-configuration.ps1 Starting at: $rundate"

# Initialise and install cloudbase - no sysprep as we are already syspreped.

Write-Output "Starting Cloud-Init"
& "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\Python\Scripts\cloudbase-init.exe" --config-file "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf"
Write-Output "Cloudbase-Init Ended"
