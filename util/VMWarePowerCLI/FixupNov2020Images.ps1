# Fixup November 2020 Windows Refresh images.
# The Jenkins Image generation jobs placed the two images for each OS on the old tintri storage.
# This script clones the machines onto the netapp storage.

# It also creates the two 2010 ipv6 machines.


# $NoConfirm = @{'Confirm'=$false}


function Get-FolderPath {
<#
.SYNOPSIS
  Returns the folderpath for a folder
.DESCRIPTION
  The function will return the complete folderpath for
  a given folder, optionally with the "hidden" folders
  included. The function also indicats if it is a "blue"
  or "yellow" folder.
.NOTES
  Authors:	Luc Dekens
.PARAMETER Folder
  On or more folders
.PARAMETER ShowHidden
  Switch to specify if "hidden" folders should be included
  in the returned path. The default is $false.
.EXAMPLE
  PS> Get-FolderPath -Folder (Get-Folder -Name "MyFolder")
.EXAMPLE
  PS> Get-Folder | Get-FolderPath -ShowHidden:$true
#>
  
  param(
  [parameter(valuefrompipeline = $true,
  position = 0,
  HelpMessage = "Enter a folder")]
  [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl[]]$Folder,
  [switch]$ShowHidden = $false
  )
  
  begin{
    $excludedNames = "Datacenters","vm","host"
  }
  
  process{
    $Folder | %{
      $fld = $_.Extensiondata
      $fldType = "yellow"
      if($fld.ChildType -contains "VirtualMachine"){
        $fldType = "blue"
      }
      $path = $fld.Name
      while($fld.Parent){
        $fld = Get-View $fld.Parent
        if((!$ShowHidden -and $excludedNames -notcontains $fld.Name) -or $ShowHidden){
          $path = $fld.Name + "\" + $path
        }
      }
      $row = "" | Select Name,Path,Type
      $row.Name = $_.Name
      $row.Path = $path
      $row.Type = $fldType
      $row
    }
  }
}

function Get-FolderPathID {
  param(
    [Parameter(Mandatory = $true)]
    [String]$FullPath
  )

  Get-folder -type VM -Name $FullPath.split('\')[-1] | ForEach-Object {$fpath= ($_ | Get-FolderPath).Path; $fid = $_.ID; if ($fpath -eq $FullPath) {  $fid}}

}



function Copy-FixTemplate {
  param(
    [Parameter(Mandatory = $true)]
    [String]$TemplateName,
    [String]$ToFolder,
    [String]$DestHostname,
    [String]$DestStorage,
    [String]$Cluster
  )

  Write-Host "Working on $TemplateName"
  # Cheat here - get-vm returns multiple VM's - just pick the first as it will do the job.
  $CurrentVM = (Get-VM -Name $TemplateName)[0]

  Write-Host "Cloning $TemplateName to $Cluster - $DestStorage/$DestHostname)"

  # https://code.vmware.com/docs/7634/cmdlet-reference/doc/New-VM.html
  new-vm -VM "$CurrentVM" -VMHost $DestHostname -Datastore $DestStorage -location (get-folder -id $ToFolder)  -Name "$TemplateName" -ResourcePool (Get-Cluster -Name $Cluster)
}

$fid_pix_templates_netapp_acceptance2 = Get-FolderPathID -FullPath 'pix\templates\netapp\acceptance2'
$fid_pix_templates_netapp_acceptance4 = Get-FolderPathID -FullPath 'pix\templates\netapp\acceptance4'

$dest_storage_acceptance2  = 'vmpooler_netapp_prod_2'
$dest_hostname_acceptance2 = 'pix-jj26-chassis1-2.ops.puppetlabs.net'
$dest_storage_acceptance4  = 'vmpooler_netapp_prod'
$dest_hostname_acceptance4 = 'pix-jj27-u21.ops.puppetlabs.net'


function Copy-FixBothTemplates {
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [String]$TemplateBaseName
  )
  process {
    $TemplateName = $TemplateBaseName + '-20201113'

    Copy-FixTemplate -TemplateName $TemplateName -ToFolder $fid_pix_templates_netapp_acceptance2 -DestHostname $dest_hostname_acceptance2 -DestStorage $dest_storage_acceptance2 -Cluster acceptance2
    Copy-FixTemplate -TemplateName $TemplateName -ToFolder $fid_pix_templates_netapp_acceptance4 -DestHostname $dest_hostname_acceptance4 -DestStorage $dest_storage_acceptance4 -Cluster acceptance4
  }
}



@(
  "win-10-1511-x86_64"
  "win-10-next-x86_64"
  "win-10-1607-x86_64",
  "win-10-1809-x86_64",
  "win-10-ent-i386",
  "win-10-ent-x86_64",
  "win-10-next-i386",
  "win-10-next-x86_64",
  "win-10-pro-x86_64",
  "win-2012-x86_64",
  "win-2012r2-core-x86_64",
  "win-2012r2-fips-x86_64",
  "win-2012r2-wmf5-x86_64",
  "win-2012r2-x86_64",
  "win-2016-core-x86_64",
  "win-2016-x86_64",
  "win-2019-core-x86_64",
  "win-2019-fr-x86_64",
  "win-2019-ja-x86_64",
  "win-2019-x86_64",
  "win-81-x86_64"
  ) | Copy-FixBothTemplates 

# Finally do the ipv6 machine clones.

function Copy-Ipv6Machines {
  param (
    [String]$ToFolder,
    [String]$DestHostname,
    [String]$DestStorage,
    [String]$Cluster
  )
  $BaseName = 'win-2016-x86_64-20201113'
  $ipv6_name = "$Basename-ipv6"
  $CurrentVM = (Get-VM -Name $BaseName)[0]

  Write-Host "Cloning $ipv6_name to $Cluster - $DestStorage/$DestHostname)"
  
  # https://code.vmware.com/docs/7634/cmdlet-reference/doc/New-VM.html
  $ipv6_vm = new-vm -VM "$CurrentVM" -VMHost $DestHostname -Datastore $DestStorage -location (get-folder -id $ToFolder) -Name "$ipv6_name" -ResourcePool (Get-Cluster -Name $Cluster)
  New-NetworkAdapter -vm $ipv6_vm -NetworkName ipv6_ds -Startconnected -WakeOnLan -Type VMXNET3
  
}

Copy-Ipv6Machines -ToFolder $fid_pix_templates_netapp_acceptance2 -DestHostname $dest_hostname_acceptance2 -DestStorage $dest_storage_acceptance2 -Cluster acceptance2
Copy-Ipv6Machines -ToFolder $fid_pix_templates_netapp_acceptance4 -DestHostname $dest_hostname_acceptance4 -DestStorage $dest_storage_acceptance4 -Cluster acceptance4


