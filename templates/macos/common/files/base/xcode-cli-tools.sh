#!/bin/sh

# from https://github.com/timsutton/osx-vm-templates

if [[ ! "$INSTALL_XCODE_CLI_TOOLS" =~ ^(true|yes|on|1|TRUE|YES|ON])$ ]]; then
    exit
fi

# Create the placeholder file that's checked by CLI updates' .dist code in Apple's SUS catalog
PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
touch $PLACEHOLDER

# Find the CLI Tools update.
# The softwareupdate -l output looks something like this:
#
#   * Command Line Tools (macOS El Capitan version 10.11) for Xcode-8.2
#       Command Line Tools (macOS El Capitan version 10.11) for Xcode (8.2), 150374K [recommended]
#    * Command Line Tools (macOS High Sierra version 10.13) for Xcode-9.2
#	    Command Line Tools (macOS High Sierra version 10.13) for Xcode (9.2), 177376K [recommended]
#   * macOS 10.13.2 Update Combo-10.13.2
#       macOS 10.13.2 Update Combo (10.13.2), 2101124K [recommended] [restart]
#
# There may be multiple versions of the command line tools available, as seen
# above - installing only the latest version seems to be sufficient.
PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')

# Install it and clean up
softwareupdate -i "$PROD" --verbose
rm $PLACEHOLDER
