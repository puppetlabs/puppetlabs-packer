# Tests the effectiveness of the bootstrap operation.
# for the moment just print out the logs.

Write-Output "Windows Update Completed"
Write-Output "========== Windows Update Log START ========"
Get-Content -Path C:\Packer\Logs\windows-update.log | ForEach-Object {Write-Output $_}
Write-Output "========== Windows Update Log END ========"

Start-Sleep -Seconds 10
