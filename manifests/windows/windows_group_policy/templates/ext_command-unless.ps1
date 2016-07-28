
# ext_command-unless.ps1 - newline is REQUIRED above
# Checking if the list of extension guids are specified

if ($PolicyType -eq 'User') {
  $currentList = (Get-GPExtensionListFromGPT).User
} else {
  $currentList = (Get-GPExtensionListFromGPT).Machine
}
$shouldList = Convert-GUIDListToHashTable -List $ExtensionList

# Check if all elements in shouldList appear in currentLis
$isFound = $true
$shouldList.GetEnumerator() | ForEach-Object -Process {
  $isFound = $isFound -and ($currentList.ContainsKey($_.Key))
}

if ($isFound) { exit 0 } else { exit 1 }