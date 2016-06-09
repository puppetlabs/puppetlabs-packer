
# command-unless.ps1 - newline is REQUIRED above
# Checking if the specified policy exists

$isFound = $false
$objPolFile = Open-PolicyFile

if ($objPolFile -ne $null) {
  $isFound = $objPolFile.Contains($PolicyKeyName,$PolicyValueName)
  if ($isFound) {
    $polEntry = $objPolFile.GetValue($PolicyKeyName,$PolicyValueName)
    
    $isFound = Compare-PolicyValueIsSameAs -objPolicyEntry $polEntry -Value $PolicyValue
  }
}

if ($isFound) { exit 0 } else { exit 1 }