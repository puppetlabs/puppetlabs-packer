# Placeholder Environment script for common variable definition.
$ErrorActionPreference = 'Stop'

# TODO Define variables in later tickets.

# Common variable definitions for packer installations and staging

$PackerStaging = "C:\Packer"
$PackerDownloads = "$PackerStaging\Downloads"
$PackerPuppet = "$PackerStaging\puppet"
$SysInternals = "$PackerStaging\SysInternals"
$CygwinDownloads = "$PackerDownloads\Cygwin"
$PackerLogs = "$PackerDownloads\Logs"

# For Puppet modules configuration
$ModulesPath = ''
$PuppetPath = "$ENV:PROGRAMFILES\Puppet Labs\Puppet\bin\puppet.bat"

$7zip = "$ENV:PROGRAMFILES\7-Zip\7z.exe"

if ($ENV:PROCESSOR_ARCHITECTURE -eq 'x86') {
  $ARCH = 'x86'
} else {
  $ARCH = 'x86_64'
}

# Function to download the packages we need - used in several scripts.

function Download-File {
param (
  [string]$url,
  [string]$file
 )
  $downloader = new-object System.Net.WebClient
  $downloader.Proxy.Credentials=[System.Net.CredentialCache]::DefaultNetworkCredentials;

  Write-Output "Downloading $url to $file"
  $completed = $false
  $retrycount = 0
  $maxretries = 20
  $delay = 10
  while (-not $completed) {
    try {
      $downloader.DownloadFile($url, $file)
      $completed = $true
    } catch {
      if ($retrycount -ge $maxretries) {
        Write-Host "Max Attempts exceeded"
        throw "Download aborting"
      } else {
        $retrycount++
        Write-Host "Download Failed $retrycount of $maxretries - Sleeping $delay"
        Start-Sleep -Seconds $delay
      }
    }
  }
}
