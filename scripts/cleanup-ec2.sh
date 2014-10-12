#!/bin/bash

rm -rf `ls -d puppet*`
rm pe.tar.gz
sed -i "s/disable_root: true/disable_root: 0/" /etc/cloud/cloud.cfg
sed -i "s/disable_root: 1/disable_root: 0/" /etc/cloud/cloud.cfg
if ! [ -d /usr/local/bin ];
then
  mkdir /usr/local/bin
fi
rm -rf /tmp/*
cat /dev/null > /var/log/wtmp
rm /root/.ssh/authorized_keys
