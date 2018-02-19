$ErrorActionPreference = "Stop"


$PackerBuildName = "$ENV:PACKER_BUILD_NAME"

if ($PackerBuildName -like "*wmf3*" -or $PackerBuildName -like "*wmf2*" ) {
    Write-Output "Removing WMF 4.0"
    Start-Process -Wait "wusa.exe" -ArgumentList "/uninstall /kb:2819745 /quiet /norestart"
    Write-Output "WMF 4.0 Removed - restart required"
} else {
    Write-Output "No need to remove PS4"
}
