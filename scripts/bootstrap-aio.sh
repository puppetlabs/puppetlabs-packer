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
    apt-get remove -y ubuntu-advantage-tools
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
    # Write a test value to disabled.plist if it does not exist
    # Puppet launchd provider fails if the file does not exist or
    # doesn't have a valid plist format
    if [ ! -f "/var/db/com.apple.xpc.launchd/disabled.plist" ]; then
      defaults write /var/db/com.apple.xpc.launchd/disabled test value
    fi

    curl --silent "${PUPPET_AIO}" -o $tmp_dir/puppet-agent.dmg
    hdiutil attach $tmp_dir/puppet-agent.dmg
    # Add puppet to $PATH environment variable
    export PATH=$PATH:/opt/puppetlabs/bin
    installer -pkg /Volumes/puppet-agent-*/puppet-agent-*.pkg -target / 
    aio_drive=$(diskutil list | grep puppet | egrep -o "disk\d*")
    diskutil unmountDisk $aio_drive
    # Software update & install xcode-commandline-tools
    PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    touch $PLACEHOLDER
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
    softwareupdate -i "$PROD" --verbose
    rm $PLACEHOLDER
  elif [[ ${PUPPET_AIO} == *".p5p" ]]; then
    sleep 20
    # Download puppet agent for solaris from PUPPET_AIO    
    curl --silent "${PUPPET_AIO}" -o $tmp_dir/puppet-agent.p5p  
    pkg install -g file:///$tmp_dir/puppet-agent.p5p pkg://puppetlabs.com/puppet-agent
    # Set puppet bin to PATH
    export PATH=$PATH:/opt/puppetlabs/bin    
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
done

printf 'Modules installed in ' ; $PUPPET_CMD module list --modulepath=/tmp/packer-puppet-masterless/manifests/modules
