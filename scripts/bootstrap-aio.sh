#!/bin/bash

tmp_dir="/tmp/packer-puppet-masterless"
mkdir -p "$tmp_dir"
# Download and install puppet-agent

if [ -n "${PC_REPO}" ]; then
  echo "Downloading and installing AIO from repo..."
  # Determin if this is RPM or DEB and Do the Right Thing (tm)
  if [[ ${PC_REPO} == *".rpm"* ]] ; then
    curl --silent "${PC_REPO}" -o $tmp_dir/pc-repo.rpm
    rpm -Uhv $tmp_dir/pc-repo.rpm
    if type dnf >/dev/null ; then
      dnf install -y puppet-agent
    else
      yum install -y puppet-agent
    fi
  elif [[ ${PC_REPO} == *".deb"* ]] ; then
    curl --silent "${PC_REPO}" -o $tmp_dir/pc-repo.deb
    dpkg -i $tmp_dir/pc-repo.deb
    apt-get update
    apt-get install -y puppet-agent
  else
    echo "Unsupported AIO package format" >&2
    exit 1
  fi
elif [ -n "${PUPPET_AIO}" ]; then
  echo "Downloading and installing AIO..."
  # Determin if this is RPM or DEB and Do the Right Thing (tm)
  if [[ ${PUPPET_AIO} == *".rpm"* ]] ; then
    curl --silent "${PUPPET_AIO}" -o $tmp_dir/puppet-agent.rpm
    rpm -Uhv $tmp_dir/puppet-agent.rpm
  elif [[ ${PUPPET_AIO} == *".deb"* ]] ; then
    curl --silent "${PUPPET_AIO}" -o $tmp_dir/puppet-agent.deb
    dpkg -i $tmp_dir/puppet-agent.deb
  else
    echo "Unsupported AIO package format" >&2
    exit 1
  fi
else
  echo "The environment variables PC_REPO or PUPPET_AIO must be provided to provision AIO." >&2
  exit 1
fi

# Show Puppet version
printf 'Puppet ' ; /opt/puppetlabs/puppet/bin/puppet --version

# Installed required modules
for i in "$@"
do
  /opt/puppetlabs/puppet/bin/puppet module install $i --modulepath=/tmp/packer-puppet-masterless/manifests/modules >/dev/null 2>&1
done

printf 'Modules installed in ' ; /opt/puppetlabs/puppet/bin/puppet module list --modulepath=/tmp/packer-puppet-masterless/manifests/modules
