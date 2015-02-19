install

url --url=http://mirrors.cat.pdx.edu/centos/5.11/os/i386/
lang en_US.UTF-8
keyboard us
network --bootproto=dhcp
rootpw --iscrypted $1$v4K9E8Wj$gZIHJ5JtQL5ZGZXeqSSsd0
firewall --disabled
authconfig --enableshadow --passalgo=sha512
selinux --disabled
timezone UTC
bootloader --location=mbr

text
skipx
zerombr

clearpart --all --initlabel
autopart

auth  --useshadow  --enablemd5
firstboot --disabled
reboot --eject

repo --name=updates --baseurl=http://mirrors.cat.pdx.edu/centos/5.11/updates/i386/
repo --name=epel --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-5&arch=i386
repo --name=puppetlabs --baseurl=http://yum.puppetlabs.com/el/5/products/i386/
repo --name=puppetdeps --baseurl=http://yum.puppetlabs.com/el/5/dependencies/i386/

%packages --ignoremissing
@base
bzip2
kernel-devel
kernel-headers
gcc
make
perl
curl
wget
nfs-utils
-ipw2100-firmware
-ipw2200-firmware
-ivtv-firmware

