# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/veewee/.vbox_version)
cd /tmp
mount -o loop /home/packer/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -rf /home/packer/VBoxGuestAdditions_*.iso

