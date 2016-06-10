#!/bin/bash

# AIO puppet-agent is currently used to provision nocm and puppet boxes.
# This script cleans up directories that may be left around
# as part of that process.

# Unmount NFS share if PUPPET_NFS provided
if [ -n "${PUPPET_NFS}" ]; then
  umount -l /opt/puppetlabs
fi

# Remove other Puppet-related files and directories
rm -rf /opt/puppetlabs
rm -rf /var/cache/puppet
