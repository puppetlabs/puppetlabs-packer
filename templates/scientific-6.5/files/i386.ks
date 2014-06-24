install

url --url=http://mirror.centos.org/centos-6/6/os/i386/
lang en_US.UTF-8
keyboard us
network --bootproto=dhcp
rootpw --iscrypted $1$v4K9E8Wj$gZIHJ5JtQL5ZGZXeqSSsd0
firewall --enabled --service=ssh
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

repo --name=epel --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=i386
repo --name=puppetlabs --baseurl=http://yum.puppetlabs.com/el/6/products/i386/
repo --name=puppetdeps --baseurl=http://yum.puppetlabs.com/el/6/dependencies/i386/

%packages --ignoremissing
@core
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
%end

