# Test that the correct OS Version and Edition has been installed.

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
