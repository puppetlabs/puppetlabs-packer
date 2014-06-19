#!/bin/bash

# Create mount point and required directories
mkdir -p /opt/puppet
mkdir -p /etc/puppetlabs
mkdir -p /var/opt/lib/pe-puppet

# Mount NFS share
mount -o ro -t nfs ${PUPPET_NFS}/${TEMPLATE} /opt/puppet

# Show Puppet version
printf 'Puppet ' ; /opt/puppet/bin/puppet --version

# Installed required modules
for i in "$@"
do
  /opt/puppet/bin/puppet module install $i --modulepath=/tmp/packer-puppet-masterless/manifests/modules >/dev/null 2>&1
done

printf 'Modules installed in ' ; /opt/puppet/bin/puppet module list --modulepath=/tmp/packer-puppet-masterless/manifests/modules
