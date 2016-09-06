
# local_gpo.ps1 - newline is REQUIRED above
$PolicyType = '<%= @policy_type %>'  # Machine or User
$PolicyKeyName = '<%= @key %>'
$PolicyValueName = '<%= @value %>'
$PolicyValue = '<%= @data %>'
$PolicyValueType = '<%= @type %>'

#Write-Host "PolicyType = $PolicyType"
#Write-Host "PolicyKeyName = $PolicyKeyName"
#Write-Host "PolicyValueName = $PolicyValueName"
#Write-Host "PolicyValue = $PolicyValue"
#Write-Host "PolicyValueType = $PolicyValueType"

$vp = $VerbosePreference
$VerbosePreference = 'SilentlyContinue'
# To import on PowerShell v3, you can use this command:
Add-Type -Language CSharp -TypeDefinition $PolFileEditorCS -ErrorAction Stop
# To make it work on PowerShell v2, use this command instead:
# Add-Type -Language CSharpVersion3 -TypeDefinition $PolFileEditorCS -ErrorAction Stop
$VerbosePreference = $vp

function Compare-PolicyValueIsSameAs($objPolicyEntry,$value) {
  $isSame = $false
  switch ($objPolicyEntry.Type)
  {
    'REG_SZ' { $isSame = ($objPolicyEntry.StringValue -eq $value)}
    'REG_DWORD' { $isSame = ($objPolicyEntry.DWORDValue -eq [int]$value)}
    Default { throw "Unknown PolEntryType $($objPolicyEntry.Type)"}
  }
  Write-Output $isSame
}

function Set-PolicySetting($objPolicy) {
  # Set the policy setting
  switch ($PolicyValueType.ToUpper()) {
    "REG_DWORD" {
      $objPolicy.SetDWORDValue($PolicyKeyName,$PolicyValueName,[int]$PolicyValue) | Out-Null
    }
    "REG_SZ" {
      $objPolicy.SetStringValue($PolicyKeyName,$PolicyValueName,$PolicyValue) | Out-Null
    }
    Default {
      throw "Unknown PolEntryType $($PolicyValueType.Type)"
      return $false
    }
  }

  # Save the policy file
  Write-Verbose "Saving the registry pol file"
  $objPolicy.SaveFile() | Out-Null

  return Invoke-IncrementGPTVersion 
}

function Open-PolicyFile([string]$policyFilePath = '', [bool]$createIfNotExist = $true) {
  if ($policyFilePath -eq '') { $policyFilePath = "$($env:systemroot)\system32\GroupPolicy\$PolicyType\registry.pol" }

  try
  {
    if ( -not (Test-Path -Path $policyFilePath) -and $createIfNotExist ) {
      Write-Verbose "Creating the registry pol file at $policyFilePath"
      $parentPath = Split-Path -Path $policyFilePath -Parent
      if (-not (Test-Path -Path $parentPath)) { New-Item -Path $parentPath -ItemType Directory | Out-Null }

      $tempPolFile = New-Object TJX.PolFileEditor.PolFile
      $tempPolFile.SaveFile($policyFilePath)
    }

    $objPolicy = New-Object TJX.PolFileEditor.PolFile
    $objPolicy.LoadFile($policyFilePath)
    Write-Verbose "Opened the registry pol file at $policyFilePath"
  }
  catch
  {
    $objPolicy = $null
    Write-Verbose "Error while opening the registry pol file at $policyFilePath"
    Write-Verbose $_
  }
  Write-Output $objPolicy
}