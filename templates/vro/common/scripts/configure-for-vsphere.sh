#!/usr/bin/env bash

### SSH CONFIG. ###

# Change the root password to the QA_ROOT_PASSWD
usermod -p `echo "${QA_ROOT_PASSWD_PLAIN}" | openssl passwd -stdin` root

# Turn off root password expiration
chage -m 0 -M -1 -W -1 -I -1 root

# Configure the SSH authorized keys
cat "${SSH_AUTHORIZED_KEYS_PATH}" > /root/.ssh/authorized_keys
rm "${SSH_AUTHORIZED_KEYS_PATH}"

### VCLOUD BOOT-STRAPPING ###

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
