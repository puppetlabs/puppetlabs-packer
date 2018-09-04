$ErrorActionPreference = 'Stop'

. C:\Packer\Scripts\windows-env.ps1

if (Test-Path "$PackerLogs\Mock.Platform" ) {
    Write-Output "Test Platform Build - exiting"
    exit 0
}

# This is using a revised Disk Zero script instead of sdelete.
# Script obtained and modified from: http://www.hurryupandwait.io/blog/how-can-we-most-optimally-shrink-a-windows-base-image

# Add in Optimize-Volume if this is present.
if (Get-Command -ErrorAction SilentlyContinue Optimize-Volume ) {
    Write-Output "Running Volume Optimizer"
    Optimize-Volume -DriveLetter C -Verbose
}
else {
    Write-Output "Optimization cmdlet not present - ignoring"
}

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

# Sleep to let console log catch up (and get captured by packer)
Start-Sleep -Seconds 20
