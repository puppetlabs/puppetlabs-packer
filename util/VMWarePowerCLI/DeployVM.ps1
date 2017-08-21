# Deploy VM
# Helper script used for the IMAGES-600 Deployment.
# This was used to do the actual cloning and saving of the current image to .Old
#

$afolder = Get-Folder -Id "Folder-group-v1802"
$tfolder = Get-Folder -Id "Folder-group-v1801"
$Datastore = "instance2_1"
$VMHost = "opdx-a0-chassis5-7.ops.puppetlabs.net"

$NoConfirm = @{'Confirm'=$false}

function CloneToProduction {
  param(
    [Parameter(Mandatory = $true)]
    [String]$SourceVM,
	[string]$DestVM

  )

	$OldVmName = "$DestVM" + ".old"
	Write-Host "Deleting Old (previous) VM: $OldVmName"
	Get-VM -location $tfolder $OldVmName | Remove-VM -DeleteFromDisk -Verbose @NoConfirm

	$CurrentVM = Get-VM -location $tfolder $DestVM
	Set-VM $CurrentVM -Name $OldVmName -Verbose @NoConfirm

	Write-Host "Cloning from $SourceVM to $DestVM"

	new-vm -VM "$SourceVM" -VMHost $VMHost -Datastore $Datastore -location $tfolder -Name "$DestVM" -Verbose

}

CloneToProduction -SourceVM "windows-7-x86_64-0.0.1" -DestVM "win-7-x86_64"
CloneToProduction -SourceVM "windows-8.1-x86_64-0.0.1" -DestVM "win-81-x86_64"

CloneToProduction -SourceVM "windows-10-i386-0.0.1" -DestVM "win-10-ent-i386"
CloneToProduction -SourceVM "windows-10-x86_64-0.0.1" -DestVM "win-10-ent-x86_64"

CloneToProduction -SourceVM "windows-2008-x86_64-0.0.1" -DestVM "win-2008-x86_64"

CloneToProduction -SourceVM "windows-2008r2-x86_64-0.0.1" -DestVM "win-2008r2-x86_64"
CloneToProduction -SourceVM "windows-2008r2-wmf5-x86_64-0.0.1" -DestVM "win-2008r2-wmf5-x86_64"

CloneToProduction -SourceVM "windows-2012-x86_64-0.0.1" -DestVM "win-2012-x86_64"

CloneToProduction -SourceVM "windows-2012r2-x86_64-0.0.1" -DestVM "win-2012r2-x86_64"
CloneToProduction -SourceVM "windows-2012r2-core-x86_64-0.0.1" -DestVM "win-2012r2-core-x86_64"
CloneToProduction -SourceVM "windows-2012r2-wmf5-x86_64-0.0.1" -DestVM "win-2012r2-wmf5-x86_64"
CloneToProduction -SourceVM "windows-2012r2-ja-x86_64-0.0.1" -DestVM "win-2012r2-ja-x86_64"

CloneToProduction -SourceVM "windows-2016-x86_64-0.0.1" -DestVM "win-2016-x86_64"
CloneToProduction -SourceVM "windows-2016-core-x86_64-0.0.1" -DestVM "win-2016-core-x86_64"
