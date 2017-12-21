#!/bin/bash
#
# Script to enable FIPS on centos/rhel. This has been tested on centos-7.

# Step 1: Disable PRELINKING.
if [ ! -f /etc/sysconfig/prelink ]; then
    echo "PRELINKING=no" > /etc/sysconfig/prelink
else
    echo "PRELINKING=no" >> /etc/sysconfig/prelink
fi

if [ -f /usr/sbin/prelink ]; then
    prelink -u -a
fi

# Step 1.5: Experimental 
# Install updated version of system openssl that is aligned with what gets installed
# as part of openssl-devel install
yum -y install openssl-1.0.2k-8.el7.x86_64

# Step 2: Install dracut-fips and dracut-fips-aesni packages
yum -y install dracut-fips
yum -y install dracut-fips-aesni

# Step 3: Find out the device details (BLOCK ID) of boot partition
boot_blkid=$(blkid `df /boot | grep "/dev" | awk 'BEGIN{ FS=" "}; {print $1}'` | awk 'BEGIN{ FS=" "}; {print $2}' | sed 's/"//g')

init_ramfs="/boot/initramfs-2.6.32-358.el6.x86_64.img"

# Step 4: Backup initramfs image and run dracut -v -f
#cp $init_ramfs "$init_ramfs".back
dracut -v -f

# Step 5: Manipulate /etc/default/grub to enable FIPs 
grub_file="/etc/default/grub"

fips_bootblk="fips=1 boot="$boot_blkid
grub_linux_cmdline=`grep -e "^GRUB_CMDLINE_LINUX" $grub_file | sed "s/\"$/ $fips_bootblk\"/"`

grep -v GRUB_CMDLINE_LINUX $grub_file > "$grub_file".bak; cp $grub_file.bak $grub_file

# Now bring in the modified line back
sed -i "/GRUB_DISABLE_RECOVERY/i \
  $grub_linux_cmdline" $grub_file

# Step 6: Generate /etc/grub2.cfg
grub2-mkconfig -o /boot/grub2/grub.cfg 
