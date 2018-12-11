#!/bin/bash

# AIO puppet-agent is currently used to provision nocm and puppet boxes.
# This script cleans up directories that may be left around
# as part of that process.

# Uninstall the AIO
if [ -n "${PC_REPO}" ] && [ "${PC_REPO}" != " " ]; then
  if type pkg >/dev/null ; then
  # Uninstall for Solaris using PC_REPO  
  pkg uninstall /system/management/puppet*
  # Uninstall hiera
  pkg uninstall pkg://solaris/library/ruby/hiera
if [[ ${PUPPET_AIO} == *".rpm"* ]] ; then
  rpm -e puppet-agent
elif [[ ${PUPPET_AIO} == *".deb"* ]] ; then
  dpkg -P puppet-agent
  #uninstall AIO for Solaris
elif type pkg >/dev/null ; then
  pkg uninstall /system/management/puppet*
  #uninstall hiera
  pkg uninstall pkg://solaris/library/ruby/hiera
  # Uninstall puppet from macos
elif [[ ${PUPPET_AIO} == *".dmg"* ]]; then
  rm -rf /var/log/puppetlabs
  rm -rf /var/run/puppetlabs 
  pkgutil --forget com.puppetlabs.puppet-agent
  # Remove daemon & plist files
  launchctl remove puppet
  rm -rf /Library/LaunchDaemons/com.puppetlabs.puppet.plist
  launchctl remove pxp-agent
  rm -rf /Library/LaunchDaemons/com.puppetlabs.pxp-agent.plist  
else
  echo "Unsupported AIO package format" >&2
  exit 1
fi
# Remove any Puppet-related files and directories
rm -rf /etc/puppetlabs
rm -rf /opt/puppetlabs