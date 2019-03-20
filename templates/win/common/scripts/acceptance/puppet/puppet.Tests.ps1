<#
  .SYNOPSIS
	Test that Puppet Run Succeeded.
  .DESCRIPTION
    At the moment just test that the succeeded file is there.
#>

. C:\Packer\Scripts\windows-env.ps1

describe 'Puppet Run Succeeded' {
    it 'wherein the succeeded file exists and is in place' {
        "$PackerLogs/Puppet.succeeded" | Should Exist
    }
}
