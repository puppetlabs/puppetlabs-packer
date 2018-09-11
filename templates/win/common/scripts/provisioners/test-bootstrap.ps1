# Tests the effectiveness of the bootstrap operation.
# for the moment just print out the logs.

Get-Content -Path C:\Packer\Logs\bootstrap-packerbuild.log | ForEach-Object {Write-Output $_}

Start-Sleep -Seconds 10
