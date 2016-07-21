
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

function Compare-PolicyValueIsSameAs($objPolicyEntry,$value)
{
  $isSame = $false
  switch ($objPolicyEntry.Type)
  {
    'REG_SZ' { $isSame = ($objPolicyEntry.StringValue -eq $value)}
    'REG_DWORD' { $isSame = ($objPolicyEntry.DWORDValue -eq [int]$value)}
    Default { throw "Unknown PolEntryType $($objPolicyEntry.Type)"}
  }
  Write-Output $isSame
}

function Set-PolicySetting($objPolicy)
{
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

  # Increment the gpt.ini version number
  Write-Verbose "Incrementing the version count"
  $gptIniPath = "$($env:systemroot)\system32\GroupPolicy\gpt.ini"
  # Default if gpt.ini does not exist
  $gptContents = @('[General]','Version=0') 
  if (Test-Path -Path $gptIniPath) {
    $gptContents = Get-Content $gptIniPath
  }

  # Get the current gpt.ini version
  $gptContents |
  ForEach-Object {
    if ($_ -match "Version=(\d+)$") {
      $currentGPVersion = [long]$matches[1]
    }
  }
  Write-Verbose "Current GP version is $currentGPVersion"

  Write-Verbose "Incrementing $PolicyType version by one"
  # Ref: https://blogs.technet.microsoft.com/grouppolicy/2007/12/14/understanding-the-gpo-version-number/
  # Ref: https://technet.microsoft.com/en-us/library/cc978247.aspx
  # User policy is upper 16bits
  # Machine policy is lower 16bits
  if ($PolicyType.ToUpper() -eq 'USER') {
    $currentGPVersion += 0x00010000
  } else {
    $currentGPVersion += 0x00000001
  }
  Write-Verbose "New GP version is $currentGPVersion"

  Write-Verbose "Writing out $($gptIniPath)..."
  $gptContents |
  ForEach-Object {
    if ($_ -match "Version=(\d+)$") {
      Write-Output "Version=$($currentGPVersion)"
    } else { Write-Output $_ }
  } | Set-Content $gptIniPath | Out-Null
  return $true
}

function Open-PolicyFile([string]$policyFilePath = '', [bool]$createIfNotExist = $true)
{
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