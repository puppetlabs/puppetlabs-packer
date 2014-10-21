#!/bin/sh

# Install pkgutil and OpenCSW software repos
yes | /usr/sbin/pkgadd -d http://mirror.opencsw.org/opencsw/pkgutil-`uname -p`.pkg all
/opt/csw/bin/pkgutil -U

/opt/csw/bin/pkgutil -y -i CSWwget
/opt/csw/bin/pkgutil -y -i CSWgtar
/opt/csw/bin/pkgutil -y -i CSWgsed
/opt/csw/bin/pkgutil -y -i CSWless
/opt/csw/bin/pkgutil -y -i CSWvim
# Installing GCC takes _forever_ and uses about 300 MB of disk space.
# Commenting the following line out will drastically shorten the build time of
# the boxes.
/opt/csw/bin/pkgutil -y -i CSWgcc4g++

# Configure sudo
/opt/csw/bin/pkgutil -y -i CSWsudo
chgrp 0 /etc/opt/csw/sudoers
ln -s /etc/opt/csw/sudoers /etc/sudoers
# Enable sudoers.d folder
/opt/csw/bin/gsed -i -e "s/^#\(includedir .*\)/\1/" /etc/sudoers

# Speed up SSH by disabling DNS checks for clients
echo "LookupClientHostnames=no" >> /etc/ssh/sshd_config

# Add /opt/csw and /usr/ucb directories to default PATH
for file in /etc/default/login /etc/default/su; do
  /opt/csw/bin/gsed -i -e 's#^\#PATH=.*$#PATH=/opt/csw/bin:/usr/sbin:/usr/bin:/usr/ucb#g' \
      -e 's#^\#SUPATH=.*$#SUPATH=/opt/csw/bin:/usr/sbin:/usr/bin:/usr/ucb#g' $file;
done

# Set loghost to be localhost so syslog is happy
/opt/csw/bin/gsed -i -e 's/localhost/localhost loghost/g' /etc/hosts
