
# gp_extensions.ps1 - newline is REQUIRED above
Function Convert-GUIDListToHashTable($list) {
  $list = $list.Replace('[','').Replace(']','')
  $output = @{}
  $list -split '}' | % {
    $guid = $_.Trim().Replace('{','')
    if ($guid -ne '') {
      $output.Add($guid.ToLower(),'found')
    }
  }

  Write-Output $output
}

Function Set-GPTExtensionGUIDs($guidList) {
  # Generate the setting string
  $settingString = '[' + ( ($guidList.GetEnumerator() | ForEach-Object -Process { Write-Output "{$($_.Key.ToUpper())}" } | Sort-Object) -join '' ) + ']'    

  if ($PolicyType.ToUpper() -eq 'USER') {
    $settingName = 'gPCUserExtensionNames'
  } else {
    $settingName = 'gPCMachineExtensionNames'
  }
  
  # Update the GPT.INI
  Write-Verbose "Updating $($settingName)=$($settingString)"
  $wasReplaced = $false
  $newGPTContent = (Get-GPTIniContents | ForEach-Object {
    if ($_ -match "$($settingName)=") {
      Write-Output "$($settingName)=$($settingString)"
      $wasReplaced = $true
    } else { Write-Output $_ }
  })
  if (-not $wasReplaced) { $newGPTContent += "$($settingName)=$($settingString)" }

  if (-not (Set-GPTIniContents -Value $newGPTContent)) { return $false }

  # Need to increment the version to take effect
  return Invoke-IncrementGPTVersion
}

Function Get-GPExtensionListFromGPT {
  $gptIniPath = "$($env:systemroot)\system32\GroupPolicy\gpt.ini"

  $MachineExtensions = @{}
  $UserExtensions = @{}

  if (Test-Path -Path $gptIniPath) {
    Get-Content $gptIniPath | ForEach-Object {
      if ($_ -match "gPCMachineExtensionNames=\[(.+)\]") {
        $MachineExtensions = (Convert-GUIDListToHashTable -List ([string]$matches[1].Trim()))
      }
      if ($_ -match "gPCUserExtensionNames=(.+)$") {
        $UserExtensions = (Convert-GUIDListToHashTable -List ([string]$matches[1].Trim()))
      }
    }
  }

  Return @{
    'Machine' = $MachineExtensions;
    'User' = $UserExtensions
  }
}
