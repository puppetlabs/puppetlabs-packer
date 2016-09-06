param()
# script-header.ps1

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

Function Get-GPTIniContents {
  $gptIniPath = "$($env:systemroot)\system32\GroupPolicy\gpt.ini"
  # Default if gpt.ini does not exist
  $gptContents = @('[General]','Version=0') 
  if (Test-Path -Path $gptIniPath) {
    $gptContents = Get-Content $gptIniPath
  } else { Write-Verbose "$gptIniPath did not exist.  Using default"}
  return $gptContents   
}

Function Set-GPTIniContents([string[]]$value) {
  $gptIniPath = "$($env:systemroot)\system32\GroupPolicy\gpt.ini"

  Write-Verbose "Writing $gptIniPath"
  $value | Out-File -FilePath $gptIniPath -Encoding ascii -Force -Confirm:$false

  return $true
}

Function Invoke-IncrementGPTVersion {
  # Get the current gpt.ini version
  Get-GPTIniContents |
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

  Write-Verbose "Updating Version=$($currentGPVersion)"
  $newGPTContent = (Get-GPTIniContents | ForEach-Object {
    if ($_ -match "Version=(\d+)$") {
      Write-Output "Version=$($currentGPVersion)"
    } else { Write-Output $_ }
  })

  return (Set-GPTIniContents -Value $newGPTContent)
}