#! /bin/bash

set -e

# PT_* are passed into the environment by Bolt.
# shellcheck disable=SC2154
KOTSADM_PASSWORD="${PT_kotsadm_password}"
# shellcheck disable=SC2154
if [ "${PT_force_ip_reset}" = 'true' ]; then
  FORCE_IP_RESET=1
fi
# shellcheck disable=SC2154
READY_WAIT_MINUTES="${PT_ready_wait_minutes:-5}"

# This is also the node name the kurl scripts expect to interact with.
CURRENT_HOSTNAME=$(hostname | tr '[:upper:]' '[:lower:]')

# This is the node name k8s was configured with.
CONFIGURED_K8S_NODE_NAME=$(grep hostname-override: /opt/replicated/kubeadm.conf | awk -e '{ print $2 }')

function hostnameAndNodenameMatch() {
  [ "${CURRENT_HOSTNAME}" = "${CONFIGURED_K8S_NODE_NAME}" ]
}

# This only needs to be run if the checked out vm has ended up with an IP address
# that no longer matches the one it had when k8s was configured.
function resetK8sIp() {
  force=$1
  current_ip=$(ip -br address | grep '^ens' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

  echo " * Checking for ip change"

  replicated_kubeadm_conf=/opt/replicated/kubeadm.conf
  configured_k8s_ip=$(grep node-ip: "${replicated_kubeadm_conf}" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

  echo "Host IP:"
  ip -br address | grep ens
  echo

  echo "Routes:"
  ip route
  echo

  echo "The current host ip is: ${current_ip}"
  echo "The current hostname is: ${CURRENT_HOSTNAME}"
  echo "And based on ${replicated_kubeadm_conf}, k8s was configured with ip:${configured_k8s_ip}, node-name:${CONFIGURED_K8S_NODE_NAME}"

  if [ "${current_ip}" = "${configured_k8s_ip}" ] && hostnameAndNodenameMatch && [ -z "${force}" ]; then
    echo "So there's nothing to reset. Starting services."
    echo
    systemctl start containerd
    systemctl start kubelet
  else
    echo "Need to reset the k8s configuration."

    ####################
    # From:
    # https://github.com/kubernetes/kubeadm/issues/338#issuecomment-460935394
    # kubelet and containerd are already stopped and containers removed.

    echo " * Backing up old kubernetes data"
    if [ -d /etc/kubernetes ]; then
      mv -n /etc/kubernetes /etc/kubernetes-backup
    fi
    if [ -d /var/lib/kubelet ]; then
      mv -n /var/lib/kubelet /var/lib/kubelet-backup
    fi
    if [ ! -e "${replicated_kubeadm_conf}.bak" ]; then
      cp "${replicated_kubeadm_conf}" "${replicated_kubeadm_conf}.bak"
    fi

    echo " * Restoring certificates"
    mkdir -p /etc/kubernetes
    cp -r /etc/kubernetes-backup/pki /etc/kubernetes
    rm /etc/kubernetes/pki/{apiserver.*,etcd/peer.*}

    # https://github.com/weaveworks/weave/issues/3731
    echo " * Reset weave database"
    rm -f /var/lib/weave/weave-netdata.db

    # ipvs may have routes to the old IP address
    echo " * Clear ipvs virtual server table"
    ipvsadm -C

    echo " * Restarting containerd"
    systemctl start containerd

    echo " * Reinitializing k8s primary with data in etcd and original replicated options updated to ${current_ip} and ${CURRENT_HOSTNAME}"
    sed -i -e "s/${configured_k8s_ip}/${current_ip}/" "${replicated_kubeadm_conf}"
    sed -i -e "s/hostname-override: ${CONFIGURED_K8S_NODE_NAME}/hostname-override: ${CURRENT_HOSTNAME}/" "${replicated_kubeadm_conf}"
    sed -i -e "s/name: ${CONFIGURED_K8S_NODE_NAME}/name: ${CURRENT_HOSTNAME}/" "${replicated_kubeadm_conf}"
    kubeadm init --ignore-preflight-errors=all --config "${replicated_kubeadm_conf}"
    echo

    echo " * Updating kubectl config"
    cp /etc/kubernetes/admin.conf ~/.kube/config

    echo " * Waiting for new node and deleting old node"
    kubectl get nodes --sort-by=.metadata.creationTimestamp
    if ! hostnameAndNodenameMatch; then
      kubectl delete node "${CONFIGURED_K8S_NODE_NAME}"
    fi
    kubectl wait --for condition=ready "node/$(kubectl get nodes --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[0].metadata.name}')"
    nodes_to_delete="$(kubectl get nodes -o jsonpath='{.items[?(@.status.conditions[0].status=="Unknown")].metadata.name}')"
    if [ -n "${nodes_to_delete}" ]; then
      kubectl delete node "${nodes_to_delete}"
    fi
    echo

    # When kube-proxy starts before kube-apiserver is ready, it fails to set up IPVS rules and then
    # fails to connect to kube-apiserver. Restart kube-proxy now that kubeadm init has started
    # kube-apiserver.
    echo " * Deleting (restarting) the system kube-proxy pod"
    kubectl -n kube-system delete pod -l k8s-app=kube-proxy
    echo

    if ! hostnameAndNodenameMatch; then
      # If we have changed the node name, the existing PersistentVolumeClaims
      # for kotsadm and minio won't mount because they will be tied to the
      # previous node name.
      echo " * Deleting kotsadm and minio persistent volume claims to reset node affinity"
      waitForPods '60s' 'kube-system openebs'
      # Resetting kotsadm-postgres pvc is straight forward.
      kubectl delete pvc --all && kubectl delete 'pod/kotsadm-postgres-0'
      # Resetting mino is complicated. It's managed during the kurl.sh install process.
      # We recreate it from the kurl installer's resources for minio.
      original_minio_vname=$(kubectl get pvc -n minio -o jsonpath='{.items[0].spec.volumeName}')
      kubectl delete pvc --all -n minio
      minio_pvc_yaml=/var/lib/kurl/kustomize/minio/pvc.yaml
      if ! [ -f "${minio_pvc_yaml}" ]; then
        echo "$(ts) Failed to find minio pvc resource at expected path: ${minio_pvc_yaml}. Has the kurl.sh installer changed?"
        exit 1
      fi
      kubectl -n minio apply -f "${minio_pvc_yaml}"
      kubectl wait --for=condition=Ready pod -n minio --timeout=60s -l app=minio
      # But the volume needs subdirectories which are also only created by the
      # kurl.sh install process. So we copy over the previous volumes contents,
      # after scaling down minio to avoid any races.
      new_minio_vname=$(kubectl get pvc -n minio -o jsonpath='{.items[0].spec.volumeName}')
      new_minio_dir="/var/openebs/local/${new_minio_vname}"
      kubectl scale -n minio deployment/minio --replicas=0
      kubectl wait -n minio --for=delete pod -l app=minio --timeout=60s
      rm -rf "${new_minio_dir:?}"/* "${new_minio_dir}"/.minio*
      cp -r "/var/openebs/local/${original_minio_vname}"/. "${new_minio_dir}"
      kubectl scale -n minio deployment/minio --replicas=1
      kubectl wait -n minio --for=condition=Ready pod -l app=minio --timeout=60s
      # Finally we delete the register pods so they reset against the new mino state.
      kubectl delete pod -n kurl -l app=registry
    fi
  fi

  systemctl enable containerd
  systemctl enable kubelet
}

function ts() {
  date +'%Y%m%d-%H:%M:%S'
}

function waitForPods() {
  wait_timeout=$1
  namespaces=$2
  if [ -z "${namespaces}" ]; then
    namespaces=$(kubectl get namespace -o name | sed -e 's/namespace\///')
  fi
  completed_or_evicted_pods=$(kubectl get pods -A | grep -E 'Completed|Evicted|Terminating' | awk '{ print $2 }')
  code=0
  for n in ${namespaces}; do
    for p in $(kubectl get pods -o name -n "${n}" | sed -e 's/pod\///'); do
      # Skip if this is a completed job or evicted pod, since they are already
      # done, and won't become 'ready'
      if ! [[ "${completed_or_evicted_pods}" =~ $p ]]; then
        echo "$(ts) Waiting on ${p} for ${wait_timeout}"
        if ! kubectl wait --for=condition=Ready "pod/${p}" -n "${n}" "--timeout=${wait_timeout}"; then
          echo "$(ts) Timed out waiting on ${p}"
          kubectl logs "pod/${p}" -n "${n}" || true
          echo
          code=1
        fi
      fi
    done
  done
  return $code
}

function restartK8s() {
  password=$1

  echo " * Waiting for k8s node to become available..."
  while ! kubectl get nodes; do
    echo "...still waiting"
    sleep 5;
  done
  echo

  echo " * Allowing node to schedule"
  kubectl uncordon "${CURRENT_HOSTNAME}"
  echo

  echo " * Waiting for all pods to be ready (~${READY_WAIT_MINUTES} minute timeout...)"
  counter=0
  until waitForPods '60s'; do
    echo "$(ts) Current pod state:"
    kubectl get pods -A
    echo "$(ts) Weave logs:"
    kubectl logs --namespace kube-system -l name=weave-net --all-containers
    echo "$(ts) Is original IP live?"
    nslookup "${configured_k8s_ip}" || true
    curl -k "https://${configured_k8s_ip}:6443" || true

    counter=$((counter + 1))
    if [ "${counter}" -gt "${READY_WAIT_MINUTES}" ]; then
      echo "Timed out waiting for pods to be ready..."
      exit 1
    fi
    echo
  done
  echo
  echo "$(ts) Final pod state:"
  kubectl get pods -A
  echo

  if [ -n "${password}" ]; then
    echo "Resetting the kotsadm password."
    kubectl kots reset-password default <<<"${password}"
  fi
}

dnf install -y bind-utils
resetK8sIp "${FORCE_IP_RESET}"
restartK8s "${KOTSADM_PASSWORD}"
