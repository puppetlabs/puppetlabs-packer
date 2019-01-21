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
  else
    echo "Unsupported AIO package format" >&2
    exit 1
  fi
elif [ -n "${PUPPET_AIO}" ]; then
  if [[ ${PUPPET_AIO} == *".rpm"* ]] ; then
    rpm -e puppet-agent
  elif [[ ${PUPPET_AIO} == *".deb"* ]] ; then
    dpkg -P puppet-agent  
  elif [ ${PUPPET_AIO} == *".dmg"* ] && [ "${PUPPET_AIO}" != " "]; then
    # Uninstall puppet from macos
    rm -rf /var/log/puppetlabs
    rm -rf /var/run/puppetlabs 
    pkgutil --forget com.puppetlabs.puppet-agent
  elif [[ ${PUPPET_AIO} == *".p5p" ]]; then
    # Uninstall puppet from Solaris using PUPPET_AIO    
    pkg uninstall puppet-agent
  else
    echo "Unsupported AIO package format" >&2
    exit 1
  fi
fi
# Remove any Puppet-related files and directories
rm -rf /etc/puppetlabs
rm -rf /opt/puppetlabs