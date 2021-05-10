#! /bin/bash

set -e
set -x

# Checkout a git repo locally on the builder for later use in the build process.
# Credentials are assumed to already be handled (so a repo Jenkins has access to).
#
# Requires the following variables passed in via custom_local_provisioning_env:
#
# A repository to clone
# REPO_URL='git@github.cim:puppetlabs/some-repo'
# A directory to clone into
# DIRECTORY='/tmp'
# A branch to checkout
# BRANCH='main'

if [ -z "${DIRECTORY}" ]; then
  echo "No DIRECTORY was set; nowhere to clone to."
  exit 1
fi

repo="${REPO_URL##*/}"

if [ -z "${repo}" ]; then
  echo "Failed to determine repository name from REPO_URL: '${REPO_URL}'"
  exit 1
fi

mkdir -p "${DIRECTORY}"
location="${DIRECTORY}/${repo}"
rm -rf "${location}" # in case image builder isn't cleaned between runs...
git clone "${REPO_URL}" "${location}"
cd "${location}" || exit
git checkout "${BRANCH}"
