# Script used to apply DISM updates to Win-2008R2 images.


$UpdateDirectory = "C:\DISM\Win-2008R2\Updates"
$WinImageFile = "C:\DISM\Win-2008R2\Win-2008R2\sources\install.wim"
$MountPoint = "C:\Dism\Win-2008R2\Mount"
$ImageIndex = "1"
$WinIsoPath = "C:\DISM\Win-2008R2\Win-2008R2.iso"
$WinDistPath = "C:\DISM\Win-2008R2\Win-2008R2"


$Cabs = Get-ChildItem -Path $UpdateDirectory -Recurse -Include *.cab | Sort LastWriteTime

dism /mount-wim /wimfile:$WinImageFile /index:$ImageIndex /mountdir:$MountPoint




$Cabtotal = $Cabs.Count
ForEach ($Cab in $Cabs) {
	$CabCount++
	Write-Host "Working on CAB File ($CabCount of $Cabtotal)  $Cab"

    DISM /image:$MountPoint /add-package /packagepath:$Cab  /loglevel:1 /logpath=.\dism-slip.log
    if ($? -eq $TRUE){
        $Cab | Out-File -FilePath .\Updates-Sucessful.log -Append
		Write-Host "Update $Cab Succeeded"
    } else {
		Write-Host "***** Update $Cab FAILED *******"
        $Cab | Out-File -FilePath .\Updates-Failed.log -Append
		exit 0
    }
}


dism /unmount-wim /mountdir:$MountPoint /commit


$IsoGen = "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"


& $IsoGen -m -o -u2 -udfver102 -bootdata:"2#p0,e,b$WinDistPath\boot\etfsboot.com#pEF,e,b$WinDistPath\efi\microsoft\boot\efisys.bin" $WinDistPath $WinIsoPath
