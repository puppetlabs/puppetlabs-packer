#!/bin/sh

# Install the virtualbox guest additions (from the ISO)
mkdir -p /tmp/vboxguest/mnt
mount -F hsfs -o ro `lofiadm -a $HOME/VBoxGuestAdditions.iso` /tmp/vboxguest/mnt

cd /tmp/vboxguest

cp mnt/VBoxSolarisAdditions.pkg .
/usr/bin/pkgtrans VBoxSolarisAdditions.pkg . all
yes | /usr/sbin/pkgadd -d . SUNWvboxguest

cd

umount /tmp/vboxguest/mnt
lofiadm -d /dev/lofi/1
rm -f "$HOME/VBoxGuestAdditions.iso"
rm -rf /tmp/vboxguest
