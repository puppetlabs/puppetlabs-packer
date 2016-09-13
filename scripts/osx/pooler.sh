#!/bin/bash

mv /tmp/vsphere-bootstrap.rb /etc/vsphere-bootstrap.rb && chmod 755 /etc/vsphere-bootstrap.rb
mv /tmp/rc.local /etc/rc.local && chmod 755 /etc/rc.local
mv /tmp/local.localhost.startup.plist /Library/LaunchDaemons/local.localhost.startup.plist \
   && chmod 644 /Library/LaunchDaemons/local.localhost.startup.plist
mkdir /var/root/.ssh && chmod 700 /var/root/.ssh && cp /tmp/authorized_keys /var/root/.ssh/authorized_keys \
  && chmod 644 /var/root/.ssh/authorized_keys && chown -R root:wheel /var/root/.ssh
mkdir /Users/osx/.ssh && chmod 700 /Users/osx/.ssh && cp /tmp/authorized_keys /Users/osx/.ssh/authorized_keys \
  && chmod 644 /Users/osx/.ssh/authorized_keys && chown -R osx:staff /Users/osx/.ssh
rm /tmp/authorized_keys
