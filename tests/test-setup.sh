#!/bin/bash

set -e

if [ ! -f packer ] ; then
    baseurl=https://releases.hashicorp.com
    project_name=packer
    arch=$(uname -m)
    if (echo "$arch" | grep x86_64 > /dev/null) ; then
        arch="amd64"
    fi
    os=$(uname |tr '[:upper:]' '[:lower:]')
    version="0.12.0"

    filename="$project_name"_"$version"_"$os"_"$arch".zip
    download_link="$baseurl"/"$project_name"/"$version"/"$filename"
    echo Attempting to download "$download_link"
    curl -s -O -L "$download_link"
    unzip "$filename"
    rm "$filename"
else
    echo "Packer already setup in current directory."
    exit 0
fi
