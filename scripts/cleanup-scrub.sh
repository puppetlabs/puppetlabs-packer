#!/bin/bash

if [[ $OSTYPE == darwin* ]]; then
# Turn off hibernation and get rid of the sleepimage
    pmset hibernatemode 0
    rm -f /var/vm/sleepimage
    OSX_VERS=$(sw_vers -productVersion | awk -F "." '{print $2}')
    if [ "$OSX_VERS" -lt 11 ] || $(csrutil status | grep -q disabled); then
        launchctl unload /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist
        sleep 5
    fi
    rm -rf /private/var/vm/swap*
    dd if=/dev/zero of=/EMPTY bs=1000000
    rm -rf /EMPTY
    sync;
else
# Clear wtmp
    cat /dev/null > /var/log/wtmp

# Zero disk
    dd if=/dev/zero of=/EMPTY bs=1M
    rm -rf /EMPTY
fi
# Remove this script
rm -rf /tmp/script.sh