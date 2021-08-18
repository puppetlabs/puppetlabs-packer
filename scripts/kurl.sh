#!/bin/bash

# These should be passed in via custom_provisioning_env
#APP='puppet-application-manager'
#CHANNEL='standalone'

set -e

#################################################################################
# Provide a script to get kubernetes back into a working state after vm checkout.

sudo mv /tmp/restart_k8s.sh /root
sudo chmod 750 /root/restart_k8s.sh

cat << EOF | sudo tee -a /etc/motd

After initial checkout, run /root/restart_k8s.sh to get the Kubernetes environment restarted.

EOF

#############################
# Install Kubernetes via Kurl
curl -sSLO https://k8s.kurl.sh/bundle/${APP}-${CHANNEL}.tar.gz
tar xzf ${APP}-${CHANNEL}.tar.gz
rm ${APP}-${CHANNEL}.tar.gz

cat install.sh | sudo bash -s airgap preserve-selinux-config

# Stop pods and Kubelet before shutdown. The packer build fills the disk with 0s to compress the
# image, which otherwise causes Kubelet to start erasing unused images that we still need. Other
# pods may also be paused in an unexpected state if left running.
echo " * Draining node"
kubectl drain localhost.localdomain --delete-local-data --ignore-daemonsets

echo " * Stopping kubelet"
systemctl stop kubelet
systemctl disable kubelet

if [ "$(pgrep -c -f /usr/bin/containerd-shim-runc-v2)" != "0" ]; then
  echo " * Clearing out any old containers"
  systemctl start containerd
  ready_pods=($(crictl pods -q --state ready))
  for p in "${ready_pods[@]}"; do
    crictl stopp "${p}" || true
  done
  pods=($(crictl pods -q))
  for p in "${pods[@]}"; do
    crictl rmp -f "${p}" || true
  done
fi

echo " * Stopping containerd"
systemctl stop containerd
systemctl disable containerd
