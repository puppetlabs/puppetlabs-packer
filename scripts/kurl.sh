#!/bin/bash

# These should be passed in via custom_provisioning_env
#APP='puppet-application-manager'
#CHANNEL='standalone'

set -e

#####################################################################################
# Provide instructions to get kubernetes back into a working state after vm checkout.

cat << EOF | sudo tee -a /etc/motd

This image requires local execution of a restart script to get k8s
up and running correctly again with its new IP.

There is a Bolt task, kurl_test::restart_k8s that will do this for you in the
private repo: https://github.com/puppetlabs/kurl_test

You can run it with Bolt if you are set up for that, or, if you have ssh-agent
forwarding set up with your puppetlabs github key you can download and execute
the script directly by running these commands:

git clone --no-checkout --depth 1 git@github.com:puppetlabs/kurl_test.git && cd kurl_test && git checkout HEAD -- tasks/restart_k8s.sh
./tasks/restart_k8s.sh

Or, without ssh-agent forwarding you can browse this link:

https://github.com/puppetlabs/kurl_test/blob/main/tasks/restart_k8s.sh

and click on the page's 'Raw' button to get a url with a token that can be used
via wget/curl to obtain the script; then execute it.

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
