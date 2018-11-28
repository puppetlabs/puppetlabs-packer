<#
  .SYNOPSIS
	Service Tests
  .DESCRIPTION
    E.g. Windows Update Disabled, Google Services Disabled
#>

. C:\Packer\Scripts\windows-env.ps1

describe 'Services Tests' {

    it 'Windows Update should be Disabled' {
        # Using Get-WIMIObject here instead Get-Service for Powershell 2 compatibility reasons.
        $WuaServStartMode = Get-WMIObject win32_service -filter "name='wuauserv'" | select -expand StartMode
        "$WuaServStartMode" | Should Match "Disabled"
    }
}
