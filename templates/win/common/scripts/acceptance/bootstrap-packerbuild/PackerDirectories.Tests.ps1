<#
  .SYNOPSIS
	Check Packer directories have been created.
  .DESCRIPTION
    This is run post-bootstrap to verify that the Packer directory set
    has been created.
#>

. C:\Packer\Scripts\windows-env.ps1

describe 'Packer Directory Tests' {
    $pdirs = @{pdir = "C:\Packer"},
             @{pdir = "C:\Packer\Logs"},
             @{pdir = "C:\Packer\Scripts"},
             @{pdir = "C:\Packer\Config"},
             @{pdir = "C:\Packer\PsModules"},
             @{pdir = "C:\Packer\Acceptance"},
             @{pdir = "C:\Packer\Downloads"},
             @{pdir = "C:\Packer\SysInternals"}

    it 'Packer Directory <pdir> should exist' -TestCases $pdirs {
        param ($pdir)
        $pdir | Should Exist
    }
}
