#!/bin/bash

# These should be passed in via custom_provisioning_env
#APP='puppet-application-manager'
#CHANNEL='standalone-beta'

set -e

#################################################################################
# Provide a script to get kubernetes back into a working state after vm checkout.
sudo yum install -y git
/usr/bin/git clone git@github.com:puppetlabs/kurl_test
sudo cp kurl_test/tasks/restart_k8s.sh /root
sudo chmod 750 /root/restart_k8s.sh
rm -rf kurl_test

sudo cat << EOF >> /etc/motd

After initial checkout, run /root/restart_k8s.sh to get the Kubernetes environment restarted.

EOF

#############################
# Install Kubernetes via Kurl
curl -sSLO https://k8s.kurl.sh/bundle/${APP}-${CHANNEL}.tar.gz
tar xzf ${APP}-${CHANNEL}.tar.gz
rm ${APP}-${CHANNEL}.tar.gz

cat << EOF > patch.yaml
apiVersion: cluster.kurl.sh/v1beta1
kind: Installer
metadata:
  name: patch
spec:
  # Disable Prometheus. Not necessary for testing and reduces resource requirements.
  prometheus:
    version: ''
EOF

dnf -y install bash-completion
cat install.sh | sudo bash -s airgap preserve-selinux-config installer-spec-file=patch.yaml
