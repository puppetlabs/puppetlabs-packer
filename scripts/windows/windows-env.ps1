# Placeholder Environment script for common variable definition.
$ErrorActionPreference = 'Stop'

# TODO Define variables in later tickets.

# Common variable definitions for packer installations and staging

$PackerStaging = "C:\Packer"
$PackerDownloads = "$PackerStaging\Downloads"
$PackerPuppet = "$PackerStaging\puppet"

# For Puppet modules configuration
$ModulesPath = ''
$PuppetPath = 'C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat'
