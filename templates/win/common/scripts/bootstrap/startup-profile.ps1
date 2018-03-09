#
# Specialised startup profile for Windows Core Installations to workaround boxstarter resumption on reboot
# issues with Windows Core
#
try {
     $startup = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs\Startup\packer-post-restart.bat"
     if (!$env:PACKER_STARTUP_WORKAROUND -and (Test-Path $startup)) {
         & cmd /c $startup
     }
 } finally {
     $env:PACKER_STARTUP_WORKAROUND = 1
 }
