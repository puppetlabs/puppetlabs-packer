#!/bin/sh
# Add vagrant user and group

date > /etc/vagrant_box_build_time

/usr/sbin/groupadd vagrant
/usr/sbin/useradd -m -d /export/home/vagrant -g vagrant vagrant

PASSWD=`perl -e 'print crypt($ARGV[0], substr(rand(data),2));' vagrant`
perl -pi -e "s/^vagrant:UP:/vagrant:$PASSWD/" /etc/shadow

# Give Vagrant sudo rights
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/vagrant

# Install vagrant keys
mkdir -pm 700 /export/home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /export/home/vagrant/.ssh/authorized_keys
chmod 0600 /export/home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /export/home/vagrant/.ssh
