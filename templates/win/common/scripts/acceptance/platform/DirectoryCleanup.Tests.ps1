<#
  .SYNOPSIS
	Directory Cleanup has happened.
  .DESCRIPTION
    A set of tests to verify that directory remnants left over
    after the Puppet run have been removed, so that any CI testing
    is running on a "Clean System".
#>

. C:\Packer\Scripts\windows-env.ps1

describe "Directory Cleanup should have happened" {

    it 'Program Data Dir Puppetlabs should not exist' {
        "$ENV:ProgramData\PuppetLabs" | Should Not Exist
    }

    it 'Program Dir Puppet Labs should not exist' {
        "$ENV:ProgramFiles\Puppet Labs" | Should Not Exist
    }

    # This test is slightly superfluous as if the Puppet Labs directory aren't thiere, this
    # will also be clear - however, if Puppet Agent is uninstalled, this .dll is kept, so
    # its useful as a belt and braces test to "prove" that a correct and full cleanup has happened.
    it 'puppetres.dll Should Not Exist' {
        "$ENV:PROGRAMFILES\Puppet Labs\Puppet\puppet\bin\puppetres.dll" | Should Not Exist
    }
}
