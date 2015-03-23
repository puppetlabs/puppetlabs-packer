#!/bin/sh
# Add vagrant user and group

date > /etc/vagrant_box_build_time

# Disable namechecking. This lets us set the password to 'vagrant' when the
# username is 'vagrant'.
/opt/csw/bin/gsed -i -e 's/^#NAMECHECK=.*$/NAMECHECK=NO/' /etc/default/passwd

/usr/sbin/groupadd vagrant
/usr/sbin/useradd -m -d /export/home/vagrant -s /usr/bin/bash -g vagrant vagrant

PASSWD=`perl -e 'print crypt($ARGV[0], substr(rand(data),2));' vagrant`
/opt/csw/bin/gsed -i -e "s/^vagrant:UP:/vagrant:$PASSWD/" /etc/shadow

# Give Vagrant sudo rights
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" > /etc/opt/csw/sudoers.d/vagrant
/usr/sbin/usermod -P'Primary Administrator' vagrant

# Install vagrant keys
mkdir -pm 700 /export/home/vagrant/.ssh
/opt/csw/bin/wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /export/home/vagrant/.ssh/authorized_keys
chmod 0600 /export/home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /export/home/vagrant/.ssh
