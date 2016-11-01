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
