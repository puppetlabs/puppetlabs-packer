<#
  .SYNOPSIS
	Platform validation tests
  .DESCRIPTION
    A set of tests to verify that the following platform attributes
    are valid
    1. Operating System Name
    2. Edition (e.g. Standard, Professional, Enterprise)
    3. Installation Type (e.g. Client, Server, ServerCore)
    4. DisplayVersion or ReleaseID - the Windows Build Version, depending on OS variant
#>

. C:\Packer\Scripts\windows-env.ps1

describe 'Windows Platform Validation Tests' {

    it 'Should be the Correct Operating System name' {
        $WindowsProductName | Should Be $($PackerBuildParams.packer.windows.productname)
    }

    it 'Should be the correct Edition' {
        $WindowsEditionID | Should Be $($PackerBuildParams.packer.windows.editionid)
    }

    it 'Should be the correct Installation Type' {
        $WindowsInstallationType | Should Be $($PackerBuildParams.packer.windows.installationtype)
    }

    if ($WindowsVersion -Like $WindowsServer2022) {
        it 'Should be the correct DisplayVersion' {
            $WindowsDisplayVersion | Should Be $($PackerBuildParams.packer.windows.displayversion)
        }
    } else {
        it 'Should be the correct ReleaseID' {
            $WindowsReleaseID | Should Be $($PackerBuildParams.packer.windows.releaseid)
        }
    }
}
