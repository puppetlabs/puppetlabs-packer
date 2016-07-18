#!/bin/bash

# Clear DHCP leases
rm -f /var/lib/dhcp3/*.leases
rm -f /var/lib/dhcp/*.leases

# Clear wtmp
cat /dev/null > /var/log/wtmp

# Zero disk
dd if=/dev/zero of=/EMPTY bs=1M
rm -rf /EMPTY

# Remove this script
rm -rf /tmp/script.sh
