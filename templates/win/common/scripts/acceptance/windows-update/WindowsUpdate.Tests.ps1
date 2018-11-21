<#
  .SYNOPSIS
    Windows Update Tests
  .DESCRIPTION
    A set of tests that PsWindowsUpdate has run and actual
    windows updates are installed.
#>
. C:\Packer\Scripts\windows-env.ps1

Import-PsWindowsUpdateModule

# Pull information from Windows Update operations.
# Updates in last 12 hours (for very long update process)
$WUHistory = get-wuhistory -Erroraction SilentlyContinue | Where-Object { [int]($(Get-Date) - $_.Date).TotalHours -le 12 }

# Pending Update List.
$WUUpdateList = get-WULIST -UpdateType Software -Erroraction SilentlyContinue -NotKBArticleID 'KB2267602'
# Following to handle Win-2008r2/Win-7 which returns $null if no updates.
If ([string]::IsNullOrEmpty($WUUpdateList)) { $WUUpdateList = @() }

# Use "our" pending reboot check as the PSWU doesn't work under winrm
$WinRebootStatus = Test-PendingReboot 

describe 'Windows Update Validation Tests' {

    it 'Should Have at least One recent Windows Update installed' {
        $WUHistory.Count | Should BeGreaterThan 0
    }

    it 'Should not have any Windows Updates Pending' {
        $WUUpdateList.Count | Should be 0
    }

    it 'Reboot Status should not be pending' {
        $WinRebootStatus | Should be $false
    }
}
