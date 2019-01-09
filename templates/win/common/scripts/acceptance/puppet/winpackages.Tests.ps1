<#
  .SYNOPSIS
	Test that Windows Packages are installed.
  .DESCRIPTION
    Tests that NotePad++, Git for Windows and Chrome is installed.
#>

. C:\Packer\Scripts\windows-env.ps1

# Google program directory is a bit strange.
$GoogleProgDir = (${env:ProgramFiles(x86)}, ${env:ProgramFiles} -ne $null)[0]

describe 'Windows Packages are installed' {

    it 'Git for Windows' {
        "$ENV:PROGRAMFILES\Git\git-bash.exe" | Should Exist
        "$ENV:PROGRAMFILES\Git\git-cmd.exe" | Should Exist
    }

    if ($PSVersionTable.PSVersion.Major -ge 4) {
        # Powershell 6 is only installed if WMF 4.0 or greater is installed.
        it 'Powershell 6' {
            "$ENV:PROGRAMFILES\PowerShell\6\pwsh.exe" | Should Exist
        }
    }

}

describe -Tag 'DesktopOnly' 'Windows Desktop Packages are installed' {
    it 'NotePad++ should be installed' {
        "$ENV:PROGRAMFILES\Notepad++\notepad++.exe" | Should Exist
    }

    it 'Chrome should be installed' {
        "$GoogleProgDir\Google\Chrome\Application\chrome.exe" | Should Exist
    }
}
