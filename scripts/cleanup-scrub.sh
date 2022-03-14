#!/bin/bash

if [[ $OSTYPE == darwin* ]]; then
# Turn off hibernation and get rid of the sleepimage
    pmset hibernatemode 0
    rm -f /var/vm/sleepimage
    MACOS_VERS=$(sw_vers -productVersion | awk -F "." '{print $1}')
    if [ "$MACOS_VERS" -lt 11 ] || $(csrutil status | grep -q disabled); then
        launchctl unload /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist
        sleep 5
    fi
    rm -rf /private/var/vm/swap*
    dd if=/dev/zero of=/EMPTY bs=1000000
    rm -rf /EMPTY
    sync;
fi

# Clear wtmp
cat /dev/null > /var/log/wtmp

# Zero disk
dd if=/dev/zero of=/EMPTY bs=1M
rm -rf /EMPTY

# Remove this script
rm -f /tmp/script.sh
