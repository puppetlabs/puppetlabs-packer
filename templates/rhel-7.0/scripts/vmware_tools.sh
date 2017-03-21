#!/bin/bash

# Make sure perl is available
yum -y install perl

# Mount the disk image
cd /tmp
mkdir /tmp/isomount
mount -t iso9660 -o loop /root/linux.iso /tmp/isomount

# Install the drivers
cp /tmp/isomount/VMwareTools-*.gz /tmp
tar -zxvf VMwareTools*.gz
./vmware-tools-distrib/vmware-install.pl -d

# Cleanup
umount isomount
rm -rf isomount /root/linux.iso VMwareTools*.gz vmware-tools-distrib
