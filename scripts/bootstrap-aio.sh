#!/bin/bash

if [[ ${TEMPLATE} == "fedora-22"* ]]; then
  echo "Updating rpcbind..."
  dnf -y upgrade rpcbind
  systemctl enable rpcbind.socket
  systemctl restart rpcbind.service
fi

# Create mount point and required directories
mkdir -p /opt/puppetlabs
mkdir /var/cache/puppet

if [ -n "${PUPPET_NFS}" ]; then
  # Mount NFS share if PUPPET_NFS set
  echo "Mounting AIO via NFS..."
  mount -o ro -t nfs "${PUPPET_NFS}/${TEMPLATE}/opt/puppetlabs" /opt/puppetlabs
else
  echo "The environment variables PUPPET_NFS must be provided to provision AIO." >&2
  exit 1
fi

# Show Puppet version
printf 'Puppet ' ; /opt/puppetlabs/puppet/bin/puppet --version

# Installed required modules
for i in "$@"
do
  /opt/puppetlabs/puppet/bin/puppet module install $i --modulepath=/tmp/packer-puppet-masterless/manifests/modules --vardir='/var/cache/puppet' >/dev/null 2>&1
done

printf 'Modules installed in ' ; /opt/puppetlabs/puppet/bin/puppet module list --modulepath=/tmp/packer-puppet-masterless/manifests/modules
