#!/bin/bash

if [[ ${TEMPLATE} == "fedora-22"* ]]; then
  echo "Updating rpcbind..."
  dnf -y upgrade rpcbind
  systemctl enable rpcbind.socket
  systemctl restart rpcbind.service
fi

# Create mount point and required directories
mkdir -p /opt/puppet
mkdir -p /etc/puppetlabs
mkdir -p /var/opt/puppetlabs/puppet

if [ -n "${PUPPET_NFS}" ]; then
  # Mount NFS share if PUPPET_NFS set
  echo "Mounting PE via NFS..."
  mount -o ro -t nfs "${PUPPET_NFS}/${TEMPLATE}" /opt/puppet
elif [ -n "${PE_URL}" ]; then
  # Install PE via tarball download if PE_URL set
  echo "Installing PE via tarball..."
  yum install -y wget
  wget --quiet "${PE_URL}/${PE_AGENT}.tar.gz" -O pe.tar.gz
  tar zxvf pe.tar.gz --strip-components=1 -C /opt/puppet
else
  echo "The environment variables PUPPET_NFS or PE_URL must be provided to provision PE." >&2
  exit 1
fi

# Show Puppet version
printf 'Puppet ' ; /opt/puppet/bin/puppet --version

# Installed required modules
for i in "$@"
do
  /opt/puppet/bin/puppet module install $i --modulepath=/tmp/packer-puppet-masterless/manifests/modules >/dev/null 2>&1
done

if [[ ${TEMPLATE} == "fedora-23"* ]]; then
  dnf -y install git
  git clone https://github.com/nibalizer/puppet-dnf /tmp/packer-puppet-masterless/manifests/modules/puppet-dnf
  dnf -y remove git
fi


printf 'Modules installed in ' ; /opt/puppet/bin/puppet module list --modulepath=/tmp/packer-puppet-masterless/manifests/modules
