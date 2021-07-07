#!/bin/bash

# from https://github.com/timsutton/osx-vm-templates

OSX_VERS=$(sw_vers -productVersion | awk -F "." '{print $2}')

# Turn off hibernation and get rid of the sleepimage
pmset hibernatemode 0
rm -f /var/vm/sleepimage

# Turn off login window screensaver on High Sierra (it seems to use an
# inordinate amount of CPU
if [ "$OSX_VERS" -eq 13 ]; then
  defaults write /Library/Preferences/com.apple.screensaver loginWindowIdleTime 0
  osascript -e 'tell application "ScreenSaverEngine" to quit'
fi

# Stop the pager process and drop swap files. These will be re-created on boot.
# Starting with El Cap we can only stop the dynamic pager if SIP is disabled.
if [ "$OSX_VERS" -lt 11 ] || $(csrutil status | grep -q disabled); then
    launchctl unload /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist
    sleep 5
fi
rm -rf /private/var/vm/swap*

dd if=/dev/zero of=/EMPTY bs=1000000
rm -f /EMPTY;
sync;

# VMware Fusion specific items
#if [ -e .vmfusion_version ] || [[ "$PACKER_BUILDER_TYPE" == vmware* ]]; then
#    # Shrink the disk
#    /Library/Application\ Support/VMware\ Tools/vmware-tools-cli disk shrink /
#fi
