$PackerScriptsDir = $Env:PACKER_SCRIPTS_DIR
. $PackerScriptsDir/windows-env.ps1

Write-Host "Downloading... Git LFS"
Download-File 'https://github.com/git-lfs/git-lfs/releases/download/v2.2.1/git-lfs-windows-2.2.1.exe' "$PackerDownloads\git-lfs-windows.exe"

# delete existing Git LFS
#del 'C:\Program Files\Git\mingw64\bin\git-lfs.exe'

Write-Host "Installing..."
$zproc = Start-Process $PackerDownloads\git-lfs-windows.exe @SprocParms -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
$zproc.WaitForExit()

Add-Path "$env:ProgramFiles\Git LFS"
$env:path = "$env:ProgramFiles\Git LFS;$env:path"

git lfs install --force
git lfs version

Write-Host "Git LFS installed" -ForegroundColor Green
