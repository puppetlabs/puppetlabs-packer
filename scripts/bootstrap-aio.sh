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
    elif type zypper >/dev/null ; then
      zypper install -y puppet-agent
    else
      yum install -y puppet-agent
    fi
  elif [[ ${PC_REPO} == *".deb"* ]] ; then
    curl --silent "${PC_REPO}" -o $tmp_dir/pc-repo.deb
    dpkg -i $tmp_dir/pc-repo.deb
    apt-get update
    apt-get install -y puppet-agent
    #used for installing puppet for solaris
  elif type pkg >/dev/null ; then
      pkg install puppet
      svccfg -s puppet:agent setprop config/server=master.oracle.com
      svccfg -s puppet:agent refresh
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
  elif [[ ${PUPPET_AIO} == *".dmg"* ]]; then
    curl --silent "${PUPPET_AIO}" -o $tmp_dir/puppet-agent.dmg
    hdiutil mount $tmp_dir/puppet-agent.dmg
    # Add puppet to $PATH environment variable
    export PATH=$PATH:/opt/puppetlabs/bin
    # Change dir to point to /Volumes/
    cd "/Volumes/"
    # Find image path
    export IMAGE_PATH=$(find . -name puppet-agent*)
    cd "$IMAGE_PATH/"
    # Find puppet agent .pkg 
    export AGENT_NAME=$(find . -name puppet-agent*.pkg)
    # Install pupet agent 
    installer -pkg $AGENT_NAME -target / 
    # Unmount disk    
    cd "$HOME"
    diskutil unmountDisk /dev/disk2 
    # Software update & install xcode-commandline-tools
    PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    touch $PLACEHOLDER
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
    softwareupdate -i "$PROD" --verbose
    rm $PLACEHOLDER
  else
    echo "Unsupported AIO package format" >&2
    exit 1
  fi
else
  echo "The environment variables PC_REPO or PUPPET_AIO must be provided to provision AIO." >&2
  exit 1
fi

# Show Puppet version
if which puppet ; then
  PUPPET_CMD=puppet
else
  PUPPET_CMD=/opt/puppetlabs/puppet/bin/puppet
fi
printf 'Puppet ' ; $PUPPET_CMD --version

# Installed required modules
for i in $@
do
 
  $PUPPET_CMD module install $i --modulepath=/tmp/packer-puppet-masterless/manifests/modules
  
  # TODO: Check if this is still an issue once we switch over to the SLES 15 GA image
  sleep_time=20
  echo "Sleeping for ${sleep_time} seconds to avoid transient networking failures ..."
  sleep ${sleep_time}
done

printf 'Modules installed in ' ; $PUPPET_CMD module list --modulepath=/tmp/packer-puppet-masterless/manifests/modules