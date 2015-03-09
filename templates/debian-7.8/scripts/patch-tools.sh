#!/bin/bash

pushd /usr/lib/vmware-tools/modules/source
if [[ ! -f vmhgfs.tar.orig ]]
then
  cp vmhgfs.tar vmhgfs.tar.orig
fi

rm -rf vmhgfs-only
tar xf vmhgfs.tar

pushd vmhgfs-only
patch -p1 < /tmp/inode.c.patch
popd

tar cf vmhgfs.tar vmhgfs-only
rm -rf vmhgfs-only
rm -rf /tmp/inode.c.patch
popd

/usr/bin/vmware-config-tools.pl --default
