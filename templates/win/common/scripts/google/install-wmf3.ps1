$ErrorActionPreference = "Stop"

$PackerBuildName = "$ENV:PACKER_BUILD_NAME"

if ($PackerBuildName -like "*wmf3*" ) {

    Write-Output "Downloading WMF 3.0"
    $msuPath = "$env:USERPROFILE\wmf-30.msu"
    $cabPath = "$Env:USERPROFILE\KB2506143"
    mkdir -Path "$cabPath"
    Write-Output "Downloading WMF 3.0"
    (New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x64.msu', $msuPath)

    Write-Output "Extracting WMF 3.0 CAB"
    Start-Process -Wait "wusa.exe" -ArgumentList "$msuPath /extract:$cabPath"
    Write-Output "Using dism.exe to install package"
    Start-Process -Wait "dism.exe" -ArgumentList "/online /loglevel:3 /add-package /norestart /PackagePath:`"$cabPath\Windows6.1-KB2506143-x64.cab`""

    $HFmsuPath = "$env:USERPROFILE\KB2842230.msu"
    $HFcabPath = "$Env:USERPROFILE\KB2842230"
    Write-Output "Downloading Hotfix "
    (New-Object Net.WebClient).DownloadFile('http://thehotfixshare.net/board/index.php?autocom=downloads&req=download&code=confirm_download&id=17844', $HFmsuPath)
    Write-Output "Extracting WMF 3.0 CAB"
    Start-Process -Wait "wusa.exe" -ArgumentList "$HFmsuPath /extract:$HFcabPath"
    Write-Output "Using dism.exe to install package"
    Start-Process -Wait "dism.exe" -ArgumentList "/online /loglevel:3 /add-package /norestart /PackagePath:`"$HFcabPath\Windows6.1-KB2842230-x64.cab`""
    
    Write-Output "WMF 3.0 installed - Re-starting"
    
} else {
    Write-Output "No need to install WMF 3.0"
}
