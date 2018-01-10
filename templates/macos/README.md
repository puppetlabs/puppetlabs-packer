# puppetlabs-packer: macOS templates

### Prerequisites

Imaging for macOS has become particularly difficult after the release of 10.12.4. At this point, to build one of these templates, **you must have:**

- Access to Puppet's internal OS image mirrors (to download the customized 10.12 ESD image)
- The common password for Puppet's pooler VMs (this is built into the 10.12 ESD image)

See Background, below, for more information.

### Building

#### 10.12 Sierra

**Base**

The 10.12 base image is the base for all other macOS builds. To build it, you will need to supply the following environment variables:

- `QA_ROOT_PASSWORD`, the common pooler VM password
    - (The username is automatically set to `osx`)
- `PACKER_VM_OUT_DIR`, the desired output directory for this build

Example:

```bash
$ QA_ROOT_PASSWORD="<common-pooler-password>" \
    PACKER_VM_OUT_DIR="./output" \
    packer build \
    -var-file=./common/vars.json \
    -var-file=./10.12/x86_64/vars.json \
    10.12/x86_64/vmware.base.json
```

**VSphere**

Once the 10.12 base build is finished, you can build and ship the 10.12 vsphere image. You will need to supply the following environment variables:

- `QA_ROOT_PASSWORD`, the common pooler VM password
    - (The username is automatically set to `osx`)
- `PACKER_VM_SRC_DIR`, the output directory from the 10.12 base build
- `PACKER_VM_OUT_DIR`, the desired output directory for this build
- All vcenter-related environment variables: `PACKER_VCENTER_HOST`, `PACKER_VCENTER_USERNAME`, `PACKER_VCENTER_PASSWORD`, `PACKER_VCENTER_DC`, `PACKER_VCENTER_CLUSTER`, `PACKER_VCENTER_DATASTORE`, `PACKER_VCENTER_FOLDER`, `PACKER_VCENTER_NET`, `PACKER_VCENTER_INSECURE`, `PACKER_SHA`

Example:

```bash
$ QA_ROOT_PASSWORD="<common-pooler-password>" \
    PACKER_VM_OUT_DIR="./output" \
    PACKER_VM_SRC_DIR="./output" \
    ... (vcenter environment variables) \
    packer build \
    -var-file=./common/vars.json \
    -var-file=./10.12/x86_64/vars.json \
    common/vmware.vsphere.nocm.json
```

#### 10.13 High Sierra

**Base**

The 10.13 base image extends the 10.12 image - **build the 10.12 base image first,** as described above.

To build the 10.13 base image, you will need to supply the following environment variables:

- `QA_ROOT_PASSWORD`, the common pooler VM password
    - (The username is automatically set to `osx`)
- `PACKER_VM_SRC_DIR`, the output directory from the 10.12 base build
- `PACKER_VM_OUT_DIR`, the desired output directory for this build

Example:

```bash
$ QA_ROOT_PASSWORD="<common-pooler-password>" \
    PACKER_VM_OUT_DIR="./output" \
    PACKER_VM_SRC_DIR="./output" \
    packer build \
    -var-file=./common/vars.json \
    -var-file=./10.13/x86_64/vars.json \
    10.13/x86_64/vmware.base.json
```

**VSphere**

Once the 10.13 base build is finished, you can build and ship the 10.13 vsphere image. You will need to supply the following environment variables:

- `QA_ROOT_PASSWORD`, the common pooler VM password
    - (The username is automatically set to `osx`)
- `PACKER_VM_SRC_DIR`, the output directory from the 10.12 base build
- `PACKER_VM_OUT_DIR`, the desired output directory for this build
- All vcenter-related environment variables: `PACKER_VCENTER_HOST`, `PACKER_VCENTER_USERNAME`, `PACKER_VCENTER_PASSWORD`, `PACKER_VCENTER_DC`, `PACKER_VCENTER_CLUSTER`, `PACKER_VCENTER_DATASTORE`, `PACKER_VCENTER_FOLDER`, `PACKER_VCENTER_NET`, `PACKER_VCENTER_INSECURE`, `PACKER_SHA`

Example:

```bash
$ QA_ROOT_PASSWORD="<common-pooler-password>" \
    PACKER_VM_OUT_DIR="./output" \
    PACKER_VM_SRC_DIR="./output" \
    ... (vcenter environment variables) \
    packer build \
    -var-file=./common/vars.json \
    -var-file=./10.13/x86_64/vars.json \
    common/vmware.vsphere.nocm.json
```

### Background

Previously, the creation of packer templates for macOS involved the following steps:

1. Download an official "Install macOS \<version\>" installer from the App Store
2. Create a customization pkg file that:
  - Sets up an SSH user account, and
  - Runs a script which:
    - enables SSH,
    - adds the SSH user to sudoers,
    - bypasses annoyances like Siri and iCloud setup dialogues, etc.
3. Use the ESD and Base System images from the official installer to build a customized autoinstaller image that:
  - Sets appropriate values for the autoinstall process (e.g. language and target disk), and
  - Installs the customization pkg after the regular install process completes.
4. Once this autoinstaller is created, use it as the basis for the packer template, which will perform other setup tasks like installing vmware tools, adding authorized ssh keys, and setting up GUI autologin for the SSH user.

Variants of this process had been used for several years by lots of community projects (for example [timsutton/osx-vm-templates](https://github.com/timsutton/osx-vm-templates)). The 10.12 ESD image referred to in our 10.12 and 10.13 templates was created this way.

**From macOS 10.12.4 onward**, this process no longer works, because any additional pkg files built into the installer must now be signed by Apple in order for the process to proceed. Simply signing the customization pkg with an Apple developer ID certificate does not seem to be sufficient. A few alternative methods have been proposed for specific use cases, but nothing has emerged as a broadly reliable solution.

For 10.12, we had created a working, customized installer image before this restriction went into effect (the 10.12 ESD mentioned in these templates); We still use that installer, then we apply system updates after the install process is finished.

For the 10.13 template we do not have a working customized installer image; Instead, we install 10.12 using our customized installer, then upgrade the system to 10.13 using its official installer.
