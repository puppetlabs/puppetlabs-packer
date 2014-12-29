# to install the following packages, epel is required
yum -y update

# Installs cloudinit
yum -y install cloud-init

# configure cloud init 'cloud-user' as sudo
# this is not configured via default cloudinit config
cat > /etc/cloud/cloud.cfg.d/02_user.cfg <<EOL
system_info:
  default_user:
    name: cloud-user
    lock_passwd: true
    gecos: Cloud user
    groups: [wheel, adm]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
EOL

# Current version does not work well with the latest cloud-init version
# Further testing is required
# Install heat-cfntools
#yum -y install python python-devel
#wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py
#python get-pip.py
#yum -y install gcc
#pip install heat-cfntools
#cfn-create-aws-symlinks --source /usr/bin

# Install haveged for entropy
yum -y install haveged

# Configure serial console

  #In order for nova console-log to work properly on CentOS 6.x
  # already done in 6.5
  # echo "serial --unit=0 --speed=115200"  >> /boot/grub/grub.conf
  # echo "terminal --timeout=10 console serial"  >> /boot/grub/grub.conf

  # Edit the kernel line to add the console entries
  # echo "kernel ... console=tty0 console=ttyS0,115200n8"  >> /boot/grub/menu.lst
sed -i '/kernel/s|$| console=tty0 console=ttyS0,115200n8 |' /boot/grub/grub.conf

# Disable the zeroconf route
echo "NOZEROCONF=yes" >> /etc/sysconfig/network
echo "PERSISTENT_DHCLIENT=yes" >> /etc/sysconfig/network

# Configure network cards and remove device specific configuration
rm -f /etc/udev/rules.d/70-persistent-net.rules
touch /etc/udev/rules.d/70-persistent-net.rules

# remove uuid
sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0

# support second network card
cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth1
sed -i 's/eth0/eth1/' /etc/sysconfig/network-scripts/ifcfg-eth1

# remove password from root
passwd -d root


