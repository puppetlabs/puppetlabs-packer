#!/usr/bin/env bash

### SSH CONFIG. ###

# This lets the user change root's password to a previous one
sed -i 's/enforce_for_root//' /etc/pam.d/common-password

# Turn off root password expiration
chage -m 0 -M -1 -W -1 -I -1 root

# Configure the SSH authorized keys
cat "${SSH_AUTHORIZED_KEYS_PATH}" > /root/.ssh/authorized_keys
rm "${SSH_AUTHORIZED_KEYS_PATH}"

### VCLOUD BOOT-STRAPPING ###

# These modifications to /etc/sysconfig/network/dhcp ensure that the
# hostname changes made by the vcloud-bootstrap script persist whenever
# the network is restarted
sed -i 's/DHCPCD_USER_OPTIONS=.*/DHCPCD_USER_OPTIONS=""/' /etc/sysconfig/network/dhcp
sed -i 's/DHCLIENT_SET_HOSTNAME=.*/DHCLIENT_SET_HOSTNAME="yes"/' /etc/sysconfig/network/dhcp
sed -i 's/DHCLIENT_USE_LAST_LEASE=.*/DHCLIENT_USE_LAST_LEASE="yes"/' /etc/sysconfig/network/dhcp

# Set-up vcloud boot-strapping
mv ${VCLOUD_BOOTSTRAP_PATH} /etc/vcloud-bootstrap
chmod 0700 /etc/vcloud-bootstrap

# Let init know about our boot-strapping script
init_dir="/etc/init.d"
ln -s "/etc/vcloud-bootstrap" "${init_dir}/rc3.d/S03vcloud-bootstrap"
echo "#!/bin/bash" > "${init_dir}/boot.vcloud-bootstrap"
echo "/etc/vcloud-bootstrap" >> "${init_dir}/boot.vcloud-bootstrap"
chmod 0755 "${init_dir}/boot.vcloud-bootstrap"
ln -s "${init_dir}/boot.vcloud-bootstrap" "${init_dir}/boot.d/S15boot.vcloud-bootstrap"
echo "/etc/vcloud-bootstrap" >> "${init_dir}/boot.local"
