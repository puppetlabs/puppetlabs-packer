$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1


# Zeroing cleaned disk space
Write-Host "Zeroing cleaned disk space using sdelete"
choco install sdelete --yes --force
if ($ARCH -eq 'x86') {
  $Sdelete = "sdelete"
} else {
  $Sdelete = "sdelete64"
}
& $Sdelete -z -accepteula c:

# Remove the pagefile
Write-Host "Removing page file.  Recreates on next boot"
reg.exe ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"    /v "PagingFiles" /t REG_MULTI_SZ /f /d """"

# Sleep to let console log catch up (and get captured by packer)
Start-Sleep -Seconds 20
