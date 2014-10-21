#!/bin/bash

# Clear wtmp
cat /dev/null > /var/log/wtmp

# Zero disk
dd if=/dev/zero of=/EMPTY bs=1M
rm -rf /EMPTY

# Remove this script
rm -rf /tmp/script.sh
