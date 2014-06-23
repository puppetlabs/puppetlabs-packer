#!/bin/bash

# Unmount NFS share
umount -l /opt/puppet

# Remove Puppet-related files and directories
rm -rf /etc/puppetlabs
rm -rf /opt/puppet
rm -rf /var/cache/yum/puppetdeps
rm -rf /var/opt/lib/pe-puppet
