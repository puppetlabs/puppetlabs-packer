<#
  .SYNOPSIS
	Date Time Tests
  .DESCRIPTION
    1. Timezone should be UTC
    2. Boot time .vs. current time test
#>

. C:\Packer\Scripts\windows-env.ps1

# Pick up the Timezone from systeminfo - with Localised Timezone Title
$Timezone = $(systeminfo | findstr  /L $TZTitle)
# Note (Get-CimInstance -class Win32_OperatingSystem).LastBootUpTime would be better here, but its not available in PS2.
# Noting for future.
$LastBoot = (Get-WmiObject -class Win32_OperatingSystem | Select-Object @{label='LastBootUpTime';expression={$_.ConvertToDateTime($_.LastBootUpTime)}}).LastBootUpTime
$CurrentTime = Get-Date

describe 'Date/Time Tests' {

    it 'Timezone is UTC' {
        "$Timezone" | Should Match "\(UTC\)"
    }

    it 'Last boot is before current time' {
        $CurrentTime | Should BeGreaterThan $LastBoot
    }
}
