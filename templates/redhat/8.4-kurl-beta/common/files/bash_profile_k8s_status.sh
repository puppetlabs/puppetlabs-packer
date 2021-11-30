###########################################################
# Provide k8s status and kots password reset info on login.

k8s_restart_state=$(/usr/sbin/check_k8s_restart_state.sh)
case "${k8s_restart_state}" in
  succeeded)
    echo 'Kubernetes reset complete.'
    echo
    echo 'Run "kubectl kots reset-password -n default" to reset the KOTS admin console root password.'
    echo
    ;;
  running)
    echo '** WARNING: Kubernetes reset still in progress.'
    echo
    echo 'Check status by running "check_k8s_restart_state.sh".'
    echo 'Or for more detail, by running "systemctl status k8s-restart" or "journalctl -u k8s-restart.service"'
    echo 
    echo 'Once the k8s-restart.service completes sucessfully, you can run "kubectl kots reset-password -n default" to reset the KOTS admin console root password.'
    echo
    ;;
  *)
    journalctl -u k8s-restart.service --no-pager
    echo
    echo '!! ERROR: Kubernetes reset failed !!'
    echo 'See "journalctl -u k8s-restart.service" above for details.'
    echo
    ;;
esac
