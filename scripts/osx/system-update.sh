#!/bin/bash

# from https://github.com/timsutton/osx-vm-templates

if [ "$UPDATE_SYSTEM" != "true" ] && [ "$UPDATE_SYSTEM" != "1" ]; then
  exit
fi

echo "Downloading and installing system updates..."
softwareupdate -i -a
