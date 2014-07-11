install

cdrom
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
net-tools
nfs-utils
-ipw2100-firmware
-ipw2200-firmware
-ivtv-firmware
%end

%post
cat >/etc/yum.repos.d/rhel7.repo <<EOF
[rhel7-os]
name=Red Hat Enterprise Linux 7 - $basearch
baseurl=http://osmirror.delivery.puppetlabs.net/rhel7latestserver-x86_64/RPMS.os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

[rhel7-optional]
name=Red Hat Enterprise Linux 7 - $basearch - Optional
baseurl=http://osmirror.delivery.puppetlabs.net/rhel7latestserver-x86_64/RPMS.optional/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

[rhel7-extras]
name=Red Hat Enterprise Linux 7 - $basearch - Extras
baseurl=http://osmirror.delivery.puppetlabs.net/rhel7latestserver-x86_64/RPMS.extras/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
EOF
%end

