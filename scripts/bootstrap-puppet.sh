#!/bin/bash

if [ -n "${PUPPET_NFS}" ]; then
  # Mount NFS share if PUPPET_NFS set
  echo "Mounting PE via NFS..."

  # Create mount point and required directories
  mkdir -p /opt/puppet
  mkdir -p /etc/puppetlabs
  mkdir -p /var/opt/puppetlabs/puppet

  mount -o ro -t nfs ${PUPPET_NFS}/${TEMPLATE} /opt/puppet
elif [ -n "${PE_URL}" ]; then
  # Install PE via tarball download if PE_URL set
  echo "Installing PE via tarball..."

  yum install -y wget

  # Debian 7 in particular won't accept our CA, so we don't verify certificates here
  wget --no-check-certificate ${PE_URL} -O pe.tar.gz

  cat > /tmp/answers <<EOF
q_all_in_one_install=n
q_continue_or_reenter_master_hostname=c
q_database_install=n
q_fail_on_unsuccessful_master_lookup=n
q_install=y
q_puppet_cloud_install=n
q_puppet_enterpriseconsole_install=n
q_puppetagent_certname=scratch.debian
q_puppetagent_install=y
q_puppetagent_server=puppet
q_puppetca_install=n
q_puppetdb_install=n
q_puppetmaster_install=n
q_run_updtvpkg=n
q_vendor_packages_install=y
EOF

  ## extract and install PE
  tar -xzvf pe.tar.gz
  cd `ls -d puppet*`
  ./puppet-enterprise-installer -a /tmp/answers
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

printf 'Modules installed in ' ; /opt/puppet/bin/puppet module list --modulepath=/tmp/packer-puppet-masterless/manifests/modules
