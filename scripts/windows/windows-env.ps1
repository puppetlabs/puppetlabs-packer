# Placeholder Environment script for common variable definition.
$ErrorActionPreference = 'Stop'

# TODO Define variables in later tickets.

# Common variable definitions for packer installations and staging

$PackerStaging = "C:\Packer"
$PackerDownloads = "$PackerStaging\Downloads"
$PackerPuppet = "$PackerStaging\puppet"
$SysInternals = "$PackerStaging\SysInternals"

# For Puppet modules configuration
$ModulesPath = ''
$PuppetPath = 'C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat'

$7zip = 'C:\Program Files\7-Zip\7z.exe'
