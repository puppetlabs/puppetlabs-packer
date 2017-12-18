#!/bin/sh

if [ $PACKER_BUILDER_TYPE = 'virtualbox-iso' ]; then
  echo "Installing VirtualBox Guest Additions"
  echo "mail=\ninstance=overwrite\npartial=quit" > /tmp/noask.admin
  echo "runlevel=nocheck\nidepend=quit\nrdepend=quit" >> /tmp/noask.admin
  echo "space=quit\nsetuid=nocheck\nconflict=nocheck" >> /tmp/noask.admin
  echo "action=nocheck\nbasedir=default" >> /tmp/noask.admin
  DEV=`/usr/sbin/lofiadm -a $HOME/VBoxGuestAdditions.iso`
  /usr/sbin/mount -o ro -F hsfs $DEV /mnt
  /usr/sbin/pkgadd -a /tmp/noask.admin -G -d /mnt/VBoxSolarisAdditions.pkg all
  /usr/sbin/umount /mnt
  /usr/sbin/lofiadm -d $DEV
  rm -f VBoxGuestAdditions.iso
fi

if [ $PACKER_BUILDER_TYPE = 'vmware-iso' ]; then
  DEV=`/usr/sbin/lofiadm -a $HOME/solaris.iso`
  mkdir /mnt2
  /usr/sbin/mount -o ro -F hsfs $DEV /mnt2
  mkdir /tmp/vmfusion-archive
  gunzip -c /mnt2/vmware-solaris-tools.tar.gz | (cd /tmp/vmfusion-archive ; tar xvf -)
  /tmp/vmfusion-archive/vmware-tools-distrib/vmware-install.pl --default
  /usr/sbin/umount /mnt2
  /usr/sbin/lofiadm -d $DEV
  rm -rf /tmp/vmfusion-archive
  rm -f solaris.iso
fi
