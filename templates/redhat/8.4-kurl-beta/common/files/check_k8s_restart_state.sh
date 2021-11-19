#! /bin/bash

state=$(systemctl show k8s-restart | grep -E '^ActiveState=' | cut -d= -f2)
case "${state}" in
  # This is a oneshot service, but systemd retains it as active if successful.
  active) state='succeeded' ;;
  # Script is still running.
  activating) state='running' ;;
  # Failed or ??
  *) ;; # return $state as is
esac

echo "${state}"
