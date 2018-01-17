
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

if ($psversiontable.psversion.major -eq 2) {
  # To make it work on PowerShell v2, use this command instead:
  #    Add-Type -Language CSharpVersion3 -TypeDefinition $PolFileEditorCS -ErrorAction Stop
  # So in the PowerShell Module (v1.0.6) uses STDIN redirection which mucks up the Add-Type call.  Go Figure!
  # Instead we need to precompile the DLL by calling CSC.EXE directly AND not using the same console process as powershell, and then import that instead.
  # Also, you can not use Add-Type -Path as it will try to use .Net 2.0 instead of 3.x/4.x as Powershell 2.0 uses .Net 2.0 by default.

  $tempDLLPath = Join-Path -Path $ENV:Temp -ChildPath "PolFileEditor.dll"
  $tempSourcePath = Join-Path -Path $ENV:Temp -ChildPath "PolFileEditor.cs"

  if (Test-Path -Path $tempDLLPath) { Remove-Item $tempDLLPath -Confirm:$false -Force | Out-Null }
  if (Test-Path -Path $tempSourcePath) { Remove-Item $tempSourcePath -Confirm:$false -Force | Out-Null }
  
  Write-Verbose "Creating temporary DLL from source..."
  $cscDir = "$($ENV:WINDIR)\Microsoft.NET\Framework\v3.5\csc.exe"
  if (-not (Test-Path -Path $cscDir)) { Throw "Could not find .Net Framework 3.5 installation" }
  $PolFileEditorCS | Set-Content $tempSourcePath
  Start-Process -FilePath $cscDir -Wait -NoNewWindow:$false -ArgumentList @('/target:library',"`"/out:$($tempDLLPath)`"","`"$($tempSourcePath)`"") 

  # Cleanup
  Remove-Item $tempSourcePath -Confirm:$false -Force | Out-Null

  # Sanity Check
  if (-not (Test-Path -Path $tempDLLPath)) { Throw "Failed to generate the temporary DLL" }

  # Import the type
  Add-Type -Path $tempDLLPath -ErrorAction Stop
}
else {
  # To import on PowerShell v3, you can use this command:
  Add-Type -Language CSharp -TypeDefinition $PolFileEditorCS -ErrorAction Stop
}
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
