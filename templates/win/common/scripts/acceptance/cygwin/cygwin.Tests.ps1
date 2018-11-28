<#
  .SYNOPSIS
	Cygwin installation tests
  .DESCRIPTION
    A set of tests to verify that Cygwin was installed and completed.
#>

. C:\Packer\Scripts\windows-env.ps1


# Basic set of initial tests - will add more correct verification of cygwin later.

describe 'Cygwin Directory Tests' {
    $cdirs = @{cdir = "$CygWinDir\bin"},
                @{cdir = "$CygWinDir\dev"},
                @{cdir = "$CygWinDir\etc"},
                @{cdir = "$CygWinDir\home"},
                @{cdir = "$CygWinDir\lib"},
                @{cdir = "$CygWinDir\sbin"},
                @{cdir = "$CygWinDir\tmp"},
                @{cdir = "$CygWinDir\usr"},
                @{cdir = "$CygWinDir\var"}

    it 'Cygwin Directory <cdir> should exist' -TestCases $cdirs {
        param ($cdir)
        $cdir | Should Exist
    }
}

describe 'Cygwin Executable Tests' {
    $cexes = @{cexe = "$CygWinDir\bin\cygcheck.exe"},
             @{cexe = "$ENV:WINDIR\system32\setup-$ARCH.exe"}

    it 'Cygwin Executable <cexe> should be installed' -TestCases $cexes {
        param ($cexe)
        $cexe | Should Exist
    }
}
