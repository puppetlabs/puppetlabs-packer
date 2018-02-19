. $PackerScriptsDir/windows-env.ps1

$exePath = "$env:USERPROFILE\7z1604-x64.exe"

Write-Output "Downloading 7-Zip..." 
Download-File "http://www.7-zip.org/a/7z1604-x64.exe" $exePath

Write-Output "Installing 7zip"
$zproc = Start-Process $exePath @SprocParms -ArgumentList "/S"
$zproc.WaitForExit()

del $exePath

$sevenZipFolder = 'C:\Program Files\7-Zip'
Add-SessionPath $sevenZipFolder
Add-Path "$sevenZipFolder"

Write-Host "7-Zip installed" -ForegroundColor Green
