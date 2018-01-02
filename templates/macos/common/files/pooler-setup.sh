#!/bin/bash
# Runs the pooler setup scripts; Ensure that the entire pooler/ directory's
# contents are copied into the target VM's /private/tmp/ directory first.

mv /private/tmp/vsphere-bootstrap.rb /etc/vsphere-bootstrap.rb && chmod 755 /etc/vsphere-bootstrap.rb
mv /private/tmp/rc.local /etc/rc.local && chmod 755 /etc/rc.local
mv /private/tmp/local.localhost.startup.plist /Library/LaunchDaemons/local.localhost.startup.plist \
	&& chmod 644 /Library/LaunchDaemons/local.localhost.startup.plist
mkdir /var/root/.ssh && chmod 700 /var/root/.ssh && cp /private/tmp/authorized_keys /var/root/.ssh/authorized_keys \
	&& chmod 644 /var/root/.ssh/authorized_keys && chown -R root:wheel /var/root/.ssh
mkdir /Users/$SSH_USERNAME/.ssh && chmod 700 /Users/$SSH_USERNAME/.ssh && cp /private/tmp/authorized_keys /Users/$SSH_USERNAME/.ssh/authorized_keys \
	&& chmod 644 /Users/$SSH_USERNAME/.ssh/authorized_keys && chown -R $SSH_USERNAME:staff /Users/$SSH_USERNAME/.ssh
rm /private/tmp/authorized_keys
