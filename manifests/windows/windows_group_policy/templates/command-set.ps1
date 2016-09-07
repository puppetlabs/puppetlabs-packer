
# command-set.ps1 - newline is REQUIRED above
# Set the policy value

$isSet = $false
$objPolFile = Open-PolicyFile

if ($objPolFile -ne $null) {
  $isSet = Set-PolicySetting $objPolFile
}

if ($isSet) { exit 0 } else { exit 1 }
# Blank line at end is also REQUIRED
