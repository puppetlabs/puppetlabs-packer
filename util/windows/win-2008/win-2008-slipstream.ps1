# Generates Slipstream ISO from image

# This script was used on a seperate Win-2012R2 machine to generate the slipstream as
# windows 2008 doesn't have DISM included with the base OS distribution. While it
# can be included using the WAIK this still can lead to problems adding updates.

$OSName = "Win-2008"
$ImageIndex = "1"

$DismBase = "C:\DISM\Win-2008"
$UpdateDirectory = "$DismBase\CABS-Merge"
$MountPoint = "$DismBase\Mount"
$WinIsoPath = "$DismBase\$OSName-SlipStream.iso"
$WinDistPath = "$DismBase\$OSName"
$WinImageFile = "$WinDistPath\sources\install.wim"
$WinPS2Files = "$DismBase\Powershell"

function Download-File {
param (
  [string]$url,
  [string]$file
 )
  $downloader = new-object System.Net.WebClient
  $downloader.Proxy.Credentials=[System.Net.CredentialCache]::DefaultNetworkCredentials;

  Write-Output "Downloading $url to $file"
  $completed = $false
  $retrycount = 0
  $maxretries = 20
  $delay = 10
  while (-not $completed) {
    try {
      $downloader.DownloadFile($url, $file)
      $completed = $true
    } catch {
      if ($retrycount -ge $maxretries) {
        Write-Host "Max Attempts exceeded"
        throw "Download aborting"
      } else {
        $retrycount++
        Write-Host "Download Failed $retrycount of $maxretries - Sleeping $delay"
        Start-Sleep -Seconds $delay
      }
    }
  }
}

# Need extra disk for this bit.
$IsoGen = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"


# Read in the exclude list of CABS to be downloaded and applied.
#


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
