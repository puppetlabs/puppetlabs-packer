# Generates Slipstream ISO from image
$OSName = "Win-7"
$ImageIndex = "1"

$DismBase = "C:\DISM\Win-7"
$UpdateDirectory = "$DismBase\CABS"
$MountPoint = "$DismBase\Mount"
$WinIsoPath = "$DismBase\$OSName-SlipStream.iso"
$WinDistPath = "$DismBase\$OSName"
$WinImageFile = "$WinDistPath\sources\install.wim"
$WinPS2Files = "$DismBase\Powershell"

# Need extra disk for this bit.
$IsoGen = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"

Remove-Item -Force $DismBase\Updates-Sucessful.log
Remove-Item -Force $DismBase\Updates-Failed.log
Remove-Item -Force -Recurse .\Win-7
& 'C:\Program Files\7-Zip\7z.exe' x .\Win-7.iso -owin-7

#
# Read in the exclude list of CABS to be ignored.
#
$ExcludedCabs = @{}
$Content = Get-Content $DismBase/slipstream-filter.txt
foreach ($CabName in $Content)
{
  $ExcludedCabs.Add("$CabName", "Ignore")
}

# Search for all CAB Files in Date Order - exclude express cab files if present as they can't be applied in a DISM command

$Cabs = Get-ChildItem -Path $UpdateDirectory -Recurse -Include *.cab -exclude *express*.cab | Sort LastWriteTime

Write-Host "Mounting $WinImageFile"
Set-ItemProperty $WinImageFile -name IsReadOnly -value $false
dism /mount-wim /wimfile:$WinImageFile /index:$ImageIndex /mountdir:$MountPoint

$Cabtotal = $Cabs.Count
ForEach ($Cab in $Cabs) {
	$CabCount++
  Write-Host "======================================================="
	Write-Host "Working on CAB File ($CabCount of $Cabtotal)  $Cab"

    if ($ExcludedCabs.ContainsKey($Cab.Name)) {
      Write-Host "Ignoring CAB"
      Continue
    }

    $DismFile = $Cab

    DISM /image:$MountPoint /add-package /packagepath:$DismFile  /loglevel:1 /logpath=$DismBase\dism-slip.log
    if ($? -eq $TRUE){
		$Cab.Name | Out-File -FilePath $DismBase\Updates-Sucessful.log -Append
		Write-Host "Update $Cab Succeeded"
    } else {
		Write-Host "***** Update $Cab FAILED *******"
		$Cab.Name | Out-File -FilePath $DismBase\Updates-Failed.log -Append
	}
}


dism /unmount-wim /mountdir:$MountPoint /commit

& $IsoGen -m -o -u2 -udfver102 -bootdata:"2#p0,e,b$WinDistPath\boot\etfsboot.com#pEF,e,b$WinDistPath\efi\microsoft\boot\efisys.bin" $WinDistPath $WinIsoPath


exit 0
