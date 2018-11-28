<#
  .SYNOPSIS
	Platform validation tests
  .DESCRIPTION
    A set of tests to verify that the following platform attributes
    are valid
    1. Operating System Name
    2. Edition (e.g. Standard, Professional, Enterprise)
    3. Installation Type (e.g. Client, Server, ServerCore)
    4. ReleaseID - the Windows 10/2016/2019 Build Version
#>

. C:\Packer\Scripts\windows-env.ps1

describe 'Windows Platform Validation Tests' {

    it 'Should be the Correct Operating System name' {
        $WindowsProductName | Should Be $ENV:PBTEST_WindowsProductName
    }

    it 'Should be the correct Edition' {
        $WindowsEditionID | Should Be $ENV:PBTEST_WindowsEditionID
    }

    it 'Should be the correct Installation Type' {
        $WindowsInstallationType | Should Be  $ENV:PBTEST_WindowsInstallationType
    }

    it 'Should be the correct Release ID' {
        $WindowsReleaseID | Should Be  $ENV:PBTEST_WindowsReleaseID
    }

}
