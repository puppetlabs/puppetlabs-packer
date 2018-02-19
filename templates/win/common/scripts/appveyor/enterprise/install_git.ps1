$PackerScriptsDir = $Env:PACKER_SCRIPTS_DIR
. $PackerScriptsDir/windows-env.ps1

Write-Host "Downloading... Git"
Download-File 'https://github.com/git-for-windows/git/releases/download/v2.16.2.windows.1/Git-2.16.2-64-bit.exe' "$PackerDownloads\Git-64-bit.exe"

Write-Output "Installing Git"
$zproc = Start-Process $PackerDownloads\git-64-bit.exe @SprocParms -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /NOICONS /COMPONENTS=`"icons,icons\quicklaunch,ext,ext\reg,ext\reg\shellhere,ext\reg\guihere,assoc,assoc_sh`" /LOG"
$zproc.WaitForExit()

Add-Path "$env:ProgramFiles\Git\cmd"
$env:path = "$env:ProgramFiles\Git\cmd;$env:path"

Add-Path "$env:ProgramFiles\Git\usr\bin"
$env:path = "$env:ProgramFiles\Git\usr\bin;$env:path"

#Remove-Item 'C:\Program Files\Git\mingw64\etc\gitconfig'
git config --global core.autocrlf input
git config --system --unset credential.helper
#git config --global credential.helper store

git --version
Write-Host "Git installed" -ForegroundColor Green
