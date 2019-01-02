<#
  .SYNOPSIS
	Test that sysinternals executables are installed.
  .DESCRIPTION
    Autologon is required to ensure Admin user is logged in
    BgInfo is required to do the splash screen.
    The remainder of the utilities are useful diagnostic tools to have.
#>

. C:\Packer\Scripts\windows-env.ps1

describe 'Sysinternal Executable Tests' {
    $sysexes = @{sysexe = "$SysInternals\Autologon.exe"},
               @{sysexe = "$SysInternals\BgInfo.exe"},
               @{sysexe = "$SysInternals\BgInfo64.exe"},
               @{sysexe = "$SysInternals\procexp.exe"},
               @{sysexe = "$SysInternals\procexp64.exe"},
               @{sysexe = "$SysInternals\Procmon.exe"},
               @{sysexe = "$SysInternals\PsExec.exe"},
               @{sysexe = "$SysInternals\PsExec64.exe"},
               @{sysexe = "$SysInternals\PsFile.exe"},
               @{sysexe = "$SysInternals\PsFile64.exe"},
               @{sysexe = "$SysInternals\PsGetSid.exe"},
               @{sysexe = "$SysInternals\PsGetSid64.exe"},
               @{sysexe = "$SysInternals\PsInfo.exe"},
               @{sysexe = "$SysInternals\PsInfo64.exe"},
               @{sysexe = "$SysInternals\pskill.exe"},
               @{sysexe = "$SysInternals\pskill64.exe"},
               @{sysexe = "$SysInternals\pslist.exe"},
               @{sysexe = "$SysInternals\pslist64.exe"},
               @{sysexe = "$SysInternals\PsLoggedon.exe"},
               @{sysexe = "$SysInternals\PsLoggedon64.exe"},
               @{sysexe = "$SysInternals\psloglist.exe"},
               @{sysexe = "$SysInternals\pspasswd.exe"},
               @{sysexe = "$SysInternals\pspasswd64.exe"},
               @{sysexe = "$SysInternals\psping.exe"},
               @{sysexe = "$SysInternals\psping64.exe"},
               @{sysexe = "$SysInternals\PsService.exe"},
               @{sysexe = "$SysInternals\PsService64.exe"},
               @{sysexe = "$SysInternals\psshutdown.exe"},
               @{sysexe = "$SysInternals\pssuspend.exe"},
               @{sysexe = "$SysInternals\pssuspend64.exe"}

    it 'Sysinternal Executable <sysexe> should be installed' -TestCases $sysexes {
        param ($sysexe)
        $sysexe | Should Exist
    }
}
