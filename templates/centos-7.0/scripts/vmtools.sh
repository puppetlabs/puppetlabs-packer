cd /tmp
mkdir -p /mnt/cdrom
mount -o loop /root/linux.iso /mnt/cdrom
tar zxf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/

mkdir -p /mnt/floppy
modprobe floppy
mount -t vfat /dev/fd0 /mnt/floppy

cd /tmp/vmware-tools-distrib

if [[ -f /mnt/cdrom/VMwareTools-9.6.2-1688356.tar.gz ]]
then
  pushd lib/modules/source
  if [ ! -f vmhgfs.tar.orig ]
  then
    cp vmhgfs.tar vmhgfs.tar.orig
  fi
  rm -rf vmhgfs-only
  tar xf vmhgfs.tar
  pushd vmhgfs-only/shared
  patch < /mnt/floppy/vmware9.compat_dcache.h.patch
  popd
  tar cf vmhgfs.tar vmhgfs-only
  rm -rf vmhgfs-only
  popd        
fi

/tmp/vmware-tools-distrib/vmware-install.pl --default
rm /root/linux.iso
umount /mnt/cdrom
rmdir /mnt/cdrom
rm -rf /tmp/VMwareTools-*
