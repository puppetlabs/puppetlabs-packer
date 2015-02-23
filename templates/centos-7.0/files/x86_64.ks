install

url --url=http://mirrors.cat.pdx.edu/centos/7/os/x86_64/
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

repo --name=updates --baseurl=http://mirrors.cat.pdx.edu/centos/7/updates/x86_64/
repo --name=epel --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-7&arch=x86_64
repo --name=puppetlabs --baseurl=http://yum.puppetlabs.com/el/7/products/x86_64/
repo --name=puppetdeps --baseurl=http://yum.puppetlabs.com/el/7/dependencies/x86_64/

%packages --ignoremissing
@core
bzip2
kernel-devel
kernel-headers
gcc
make
net-tools
patch
perl
curl
wget
nfs-utils
-ipw2100-firmware
-ipw2200-firmware
-ivtv-firmware
%end

