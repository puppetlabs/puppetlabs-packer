
# ext_command-set.ps1 - newline is REQUIRED above
# Setting the list of extension guids

$isSet = $false

if ($PolicyType -eq 'User') {
  $currentList = (Get-GPExtensionListFromGPT).User
} else {
  $currentList = (Get-GPExtensionListFromGPT).Machine
}
$shouldList = Convert-GUIDListToHashTable -List $ExtensionList

# Append missing elements from shouldList into currentLis
$shouldList.GetEnumerator() | ForEach-Object -Process {
  if (-not $currentList.ContainsKey($_.Key)) {
    $currentList.Add($_.Key, $_.Value)
  }
}
$isSet = Set-GPTExtensionGUIDs -GUIDList $currentList

if ($isSet) { exit 0 } else { exit 1 }
