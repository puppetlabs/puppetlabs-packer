# Establish the Goole Setup Environment.
# This is as a native script from the source machine.
# We may setup Windows-Env in future to do this bootstrapping.

# Common variable definitions for packer installations and staging
$PackerStaging = "C:\Packer"
$PackerDownloads = "$PackerStaging\Downloads"
$PackerPuppet = "$PackerStaging\puppet"
$PackerScripts = "$PackerStaging\Scripts"
$SysInternals = "$PackerStaging\SysInternals"
$PackerLogs = "$PackerStaging\Logs"
$CygwinDownloads = "$PackerDownloads\Cygwin"

# Helper to create consistent staging directories.
function Create-PackerStagingDirectories {
    if (-not (Test-Path "$PackerStaging")) {
      Write-Host "Creating $PackerStaging"
      mkdir -Path $PackerStaging\puppet\modules
      mkdir -Path $PackerStaging\Downloads
      mkdir -Path $PackerStaging\Downloads\Cygwin
      mkdir -Path $PackerStaging\Init
      mkdir -Path $PackerStaging\Scripts
      mkdir -Path $PackerStaging\Logs
      mkdir -Path $PackerStaging\Sysinternals
    }
  }


Create-PackerStagingDirectories
