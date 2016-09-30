$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

$WindowsVersion = (Get-WmiObject win32_operatingsystem).version
# Cleanup Windows Update area after all that
# Note /ResetBase option is not available on Windows-2012, so need to screen for this.
Write-Host "Cleaning up WinxSx updates"
if ($WindowsVersion -eq '6.2.9200') {
  dism /online /Cleanup-Image /StartComponentCleanup
  dism /online /cleanup-image /SPSuperseded
} else {
  dism /online /Cleanup-Image /StartComponentCleanup /ResetBase
  dism /online /cleanup-image /SPSuperseded
}

# Zeroing cleaned disk space
Write-Host "Zeroing cleaned disk space using sdelete"
choco install sdelete --yes --force
if ($ARCH -eq 'x86') {
  $Sdelete = "sdelete"
} else {
  $Sdelete = "sdelete64"
}
& $Sdelete -z -accepteula c:
