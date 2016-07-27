# Registry and other settings that are easier done outside puppet for the moment.
# These tend to be OS specific so will be left in the OS area.
#
$ErrorActionPreference = "Stop"

. A:\windows-env.ps1

# Some other quick win settings provided by Boxstarter
# Although this is no longer run under boxstarter, we are still able to use it's cmdlets.
Write-Host "Other Stuff......."

#Disable UAC for Windows-2012
Disable-UAC

# Enable Remote Desktop (with reduce authentication resetting here again)
Enable-RemoteDesktop -DoNotRequireUserLevelAuthentication
