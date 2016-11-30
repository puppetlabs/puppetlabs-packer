# Generates Slipstream ISO from image
param (
  [string]$OSName = "UNKNOWN",
  [string]$ImageIndex = "1",
  [string]$PatchSearch = "*.cab"
)

$ErrorActionPreference = 'Stop'

. C:\Packer\Dism\windows-env.ps1

New-Item -ItemType directory -Force -Path C:\Packer\Dism\$OSName

$UpdateDirectory = "$ENV:Windir\SoftwareDistribution\Download"
$DismBase = "$PackerStaging\Dism"
$MountPoint = "$DismBase\Mount"
$WinIsoPath = "$DismBase\$OSName-SlipStream.iso"
$WinDistPath = "$DismBase\$OSName"
$WinImageFile = "$WinDistPath\sources\install.wim"

# Install ADK
Write-Host "Install Win ADK"
Download-File http://buildsources.delivery.puppetlabs.net/windows/winadk/adksetup_win2012r2.exe  $PackerDownloads\adksetup_win2012r2.exe
Start-Process -Wait "$PackerDownloads\adksetup_win2012r2.exe" -ArgumentList "/quiet /norestart /features OptionId.DeploymentTools"
Write-Host "Win ADK Installed"

# Need extra disk for this bit.
$IsoGen = "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
if ($psversiontable.psversion.major -gt 2) {
  $size = (Get-PartitionSupportedSize -DriveLetter C)
  $sizemax = $size.SizeMax
  Write-Host "Setting Drive C partition size to $sizemax"
  Resize-Partition -DriveLetter C -Size $sizemax
}
else {
  Write-Host "Using DiskPart to extend C: drive partition"
  $diskpartcommands=@"
list disk
select disk 0
list partition
select partition 3
extend
list partition
exit
"@

  $diskpartcommands | diskpart
}

# Use Robocopy to make duplicate of Image ISO
Write-Host "Copy Image ISO to $WinDistPath"
robocopy /E /NP /NDL /NFL D:\ $WinDistPath *.*

# Read in the exclude list of CABS to be ignored.
#
$ExcludedCabs = @{}
$Content = Get-Content $DismBase/slipstream-filter
foreach ($CabName in $Content)
{
  $ExcludedCabs.Add("$CabName", "Ignore")
}

# Search for all CAB Files in Date Order - exclude express cab files if present as they can't be applied in a DISM command

$Cabs = Get-ChildItem -Path $UpdateDirectory -Recurse -Include "$PatchSearch" -Exclude *Express*.cab | Sort LastWriteTime

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

    DISM /image:$MountPoint /add-package /packagepath:$Cab  /loglevel:1 /logpath=$DismBase\dism-slip.log
    if ($? -eq $TRUE){
      $Cab.Name | Out-File -FilePath $DismBase\Updates-Sucessful.log -Append
		  Write-Host "Update $Cab Succeeded"
    } else {
		  Write-Host "***** Update $Cab FAILED *******"
      $Cab.Name | Out-File -FilePath $DismBase\Updates-Failed.log -Append
    }
}

$WindowsVersion = (Get-WmiObject win32_operatingsystem).version
if ($WindowsVersion -eq '6.1.7601' ) {
  # Windows 2008R2/Win-7 - just set registry keys for cleanmgr utility
  Write-Host "Skipping Cleanup"
}
ElseIf ($WindowsVersion -eq '6.2.9200' -or $WindowsVersion -eq '6.0.6002') {
  # Note /ResetBase option is not available on Windows-2012, so need to screen for this.
  dism /image:$MountPoint /Cleanup-Image /StartComponentCleanup
} else {
  dism /image:$MountPoint /Cleanup-Image /StartComponentCleanup /ResetBase
}

dism /unmount-wim /mountdir:$MountPoint /commit

& $IsoGen -m -o -u2 -udfver102 -bootdata:"2#p0,e,b$WinDistPath\boot\etfsboot.com#pEF,e,b$WinDistPath\efi\microsoft\boot\efisys.bin" $WinDistPath $WinIsoPath
