#!/bin/bash -xv
#
# Exit on Error if the following key variables are NOT defined.
# IMAGE_PROVISIONER
# 
if [ -z "${IMAGE_PROVISIONER}" ]; then echo "IMAGE_PROVISIONER not set - exit" ; exit 1; fi
export WIN_COMMON_DIR=$(dirname $0)

# Derive parameters from json variable file.
#
export PACKER_PROD_KEY=`jq -r .product_key vars.json`
export PACKER_IMAGE_NAME=`jq -r .image_name vars.json`
export PACKER_WIN_VERSION=`jq -r .windows_version vars.json`

# Firmware if needed - otherwise default to "efi"
export PACKER_FIRMWARE=`jq -r '.firmware //empty' vars.json`
[ -z "${PACKER_FIRMWARE}" ] && export PACKER_FIRMWARE="efi"

# PACKER_WIN_PROC_ARCH defaults to "amd64" unless specified
# These values are specific to the Autounattend.xml files and differ from
# the x86_64/i836 values used throughout the rest of the build system.
export PACKER_WIN_PROC_ARCH=`jq -r '.win_proc_arch //empty' vars.json`
[ -z "${PACKER_WIN_PROC_ARCH}" ] && export PACKER_WIN_PROC_ARCH="amd64"

# Locale or default to en-US (US English)
export PACKER_LOCALE=`jq -r '.locale //empty' vars.json`
[ -z "${PACKER_LOCALE}" ] && export PACKER_LOCALE="en-US"

# Need to pick up Admin Password and winrm either from local or common file - precedence with local
export PACKER_WINRM_USER=`jq -r '.winrm_username //empty' vars.json`
[ -z "${PACKER_WINRM_USER}" ] && export PACKER_WINRM_USER=`jq -r .winrm_username ${WIN_COMMON_DIR}/vars.json`
export PACKER_WINRM_PSWD=`jq -r '.winrm_password //empty' vars.json`
[ -z "${PACKER_WINRM_PSWD}" ] && export PACKER_WINRM_PSWD=`jq -r .winrm_password ${WIN_COMMON_DIR}/vars.json`

# Make sure tmp directory exists.
mkdir -p tmp

# Create base Autounattend.xml file
xsltproc --stringparam ProcessorArchitecture "${PACKER_WIN_PROC_ARCH}" \
         --stringparam ProductKey "${PACKER_PROD_KEY}" \
         --stringparam ImageName "${PACKER_IMAGE_NAME}" \
         --stringparam WindowsVersion "${PACKER_WIN_VERSION}" \
         --stringparam ImageProvisioner "${IMAGE_PROVISIONER}" \
         --stringparam Firmware "${PACKER_FIRMWARE}" \
         --stringparam WinRmUsername "${PACKER_WINRM_USER}" \
         --stringparam WinRmPassword "${PACKER_WINRM_PSWD}" \
         --stringparam Locale "${PACKER_LOCALE}" \
         -o tmp/autounattend.xml ${WIN_COMMON_DIR}/files/Autounattend.xslt ${WIN_COMMON_DIR}/files/AutoUnattendTemplate.xml

# Create the Post Clone Autounattend file.
xsltproc --stringparam ProcessorArchitecture "${PACKER_WIN_PROC_ARCH}" \
         --stringparam ProductKey "${PACKER_PROD_KEY}" \
         --stringparam ImageName "${PACKER_IMAGE_NAME}" \
         --stringparam WindowsVersion "${PACKER_WIN_VERSION}" \
         --stringparam ImageProvisioner "${IMAGE_PROVISIONER}" \
         --stringparam Firmware "${PACKER_FIRMWARE}" \
         --stringparam WinRmUsername "${PACKER_WINRM_USER}" \
         --stringparam WinRmPassword "${PACKER_WINRM_PSWD}" \
         --stringparam Locale "${PACKER_LOCALE}" \
         -o ./tmp/post-clone.autounattend.xml ${WIN_COMMON_DIR}/files/Autounattend.xslt ${WIN_COMMON_DIR}/files/PostCloneTemplate.xml

# Generate a Vagrant file template if doing virtual box

if [ "${IMAGE_PROVISIONER}" = "virtualbox" ] ;then
    echo "Generating vagrantfile template"
    # Beware - Names must not contain Underyscores.
    export PACKER_VB_HOSTNAME=`jq -r .template_name vars.json | tr '_' '-'`
    export PACKER_BEAKER_NAME_TR=`jq -r .beakerhost vars.json | tr '_' '-'`

    erb vm_box=winpacker/${PACKER_BEAKER_NAME_TR} \
        vm_hostname=${PACKER_VB_HOSTNAME} \
            ${WIN_COMMON_DIR}/files/virtualbox/vagrantfile-windows.template.erb > ./tmp/vagrantfile-windows.template
fi
