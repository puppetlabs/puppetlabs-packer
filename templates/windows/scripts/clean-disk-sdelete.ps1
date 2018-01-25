$ErrorActionPreference = 'Stop'

. A:\windows-env.ps1

# This is using a revised Disk Zero script instead of sdelete.
# Script obtained and modified from: http://www.hurryupandwait.io/blog/how-can-we-most-optimally-shrink-a-windows-base-image

Write-Output "Wiping empty space on disk..."
$FilePath="c:\zero.tmp"
$Volume = Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'"
$ArraySize= 64kb
$SpaceToLeave= $Volume.Size * 0.02
$FileSize= $Volume.FreeSpace - $SpacetoLeave
$ZeroArray= new-object byte[]($ArraySize)

$Stream= [io.File]::OpenWrite($FilePath)
try {
   $CurFileSize = 0
    while($CurFileSize -lt $FileSize) {
        $Stream.Write($ZeroArray,0, $ZeroArray.Length)
        $CurFileSize +=$ZeroArray.Length
    }
}
finally {
    if($Stream) {
        $Stream.Close()
    }
}
Remove-Item $FilePath -Force -ErrorAction SilentlyContinue

# Remove the pagefile
Write-Output "Removing page file.  Recreates on next boot"
reg.exe ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"    /v "PagingFiles" /t REG_MULTI_SZ /f /d """"

# Sleep to let console log catch up (and get captured by packer)
Start-Sleep -Seconds 20
