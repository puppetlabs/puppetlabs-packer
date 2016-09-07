$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

# Cleanup Windows Update area after all that (may need reboot)
Write-Host "Cleaning up WinxSx updates"
dism /online /Cleanup-Image /StartComponentCleanup /ResetBase

# Zeroing cleaned disk space
Write-Host "Zeroing cleaned disk space using sdelete"
choco install sdelete --yes --force
if ($ARCH -eq 'x86') {
  $Sdelete = "sdelete"
} else {
  $Sdelete = "sdelete64"
}
& $Sdelete -z -accepteula c:
