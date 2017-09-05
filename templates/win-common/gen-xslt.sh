#!/bin/bash -xv
#
# Exit on Error if the following key variables are NOT defined.
#
# IMAGE_TYPE
# IMAGE_ARCH
if [ -z "${IMAGE_ARCH}" ]; then echo "IMAGE_ARCH not set - exit" ; exit 1; fi
if [ -z "${IMAGE_TYPE}" ]; then echo "IMAGE_TYPE not set - exit" ; exit 1; fi
if [ -z "${TEMPLATE_DIR}" ]; then echo "TEMPLATE_DIR not set - exit" ; exit 1; fi

if [ "${IMAGE_ARCH}" = "x86_64" ]
then
   export PACKER_PROC_ARCH="amd64" 
else
   export PACKER_PROC_ARCH="x86" 
fi

# Derive parameters from json variable file.
#
export PACKER_PROD_KEY=`jq -r .product_key ${TEMPLATE_DIR}/${IMAGE_ARCH}.vars.json`
export PACKER_IMAGE_NAME=`jq -r .image_name ${TEMPLATE_DIR}/${IMAGE_ARCH}.vars.json`
export PACKER_WIN_VERSION=`jq -r .windows_version ${TEMPLATE_DIR}/${IMAGE_ARCH}.vars.json`

# Firmware if needed - otherwise default to "efi"
export PACKER_FIRMWARE=`jq -r '.firmware //empty' ${TEMPLATE_DIR}/${IMAGE_ARCH}.vars.json`
[ -z "${PACKER_FIRMWARE}" ] && export PACKER_FIRMWARE="efi"

# Locale or default to en-US (US English)
export PACKER_LOCALE=`jq -r '.locale //empty' ${TEMPLATE_DIR}/${IMAGE_ARCH}.vars.json`
[ -z "${PACKER_LOCALE}" ] && export PACKER_LOCALE="en-US"

# Need to pick up Admin Password and winrm from Generic File.
export PACKER_WINRM_USER=`jq -r '.variables.winrm_username //empty' ${TEMPLATE_DIR}/../win-common/${IMAGE_TYPE}.base.json`
export PACKER_WINRM_PSWD=`jq -r '.variables.winrm_password //empty' ${TEMPLATE_DIR}/../win-common/${IMAGE_TYPE}.base.json`

# Make sure tmp directory exists.
mkdir -p tmp

# Create base Autounattend.xml file
xsltproc --stringparam ProcessorArchitecture "${PACKER_PROC_ARCH}" \
         --stringparam ProductKey "${PACKER_PROD_KEY}" \
         --stringparam ImageName "${PACKER_IMAGE_NAME}" \
         --stringparam WindowsVersion "${PACKER_WIN_VERSION}" \
         --stringparam ImageType "${IMAGE_TYPE}" \
         --stringparam Firmware "${PACKER_FIRMWARE}" \
         --stringparam WinRmUsername "${PACKER_WINRM_USER}" \
         --stringparam WinRmPassword "${PACKER_WINRM_PSWD}" \
         --stringparam Locale "${PACKER_LOCALE}" \
         -o tmp/autounattend.xml ../win-common/files/Autounattend.xslt ../win-common/files/AutoUnattendTemplate.xml

# Create the Post Clone Autounattend file.
xsltproc --stringparam ProcessorArchitecture "${PACKER_PROC_ARCH}" \
         --stringparam ProductKey "${PACKER_PROD_KEY}" \
         --stringparam ImageName "${PACKER_IMAGE_NAME}" \
         --stringparam WindowsVersion "${PACKER_WIN_VERSION}" \
         --stringparam ImageType "${IMAGE_TYPE}" \
         --stringparam Firmware "${PACKER_FIRMWARE}" \
         --stringparam WinRmUsername "${PACKER_WINRM_USER}" \
         --stringparam WinRmPassword "${PACKER_WINRM_PSWD}" \
         --stringparam Locale "${PACKER_LOCALE}" \
         -o tmp/post-clone.autounattend.xml ../win-common/files/Autounattend.xslt ../win-common/files/PostCloneTemplate.xml