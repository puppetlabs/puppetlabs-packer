#!/bin/bash

# These should be passed in via custom_provisioning_env
#APP='cd4pe'
#CHANNEL='beta'

set -e

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
