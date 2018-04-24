# puppetlabs-packer

### About

This contains the vmware.vsphere.nocm image template for VRO VMs, as well as all of the var files
required to build it.

Currently, only VRO 7.3 is supported for the 64-bit architecture.

### Building

All templates must be built in the `<os_dist>/<variant>/<arch>` directory. Make sure that the environment variable PACKER\_VM\_OUT\_DIR is set so that Packer knows where to copy the build artifacts (it is common to set it to ".", the current `<os_dist>/<variant>/<arch>` directory). If you are building a template with a vmware-vmx builder, be sure to set the PACKER\_VM\_SRC\_DIR environment variable to the directory containing the directory containing the relevant vm files. It is common to set PACKER\_VM\_SRC\_DIR = PACKER\_VM\_OUT\_DIR to make it easy to build a vmware-vmx template from a previous vmware build.

To build the vmware.vsphere.nocm image, you will need to manually create the VMWare base image from the downloaded, VMWare provided OVA. This is done via. the following steps:
1. Change the Network adapter settings for the VM to use a 'Shared Network' instead of 'Bridged Networking' 
2. Shutdown the VM, and then export the resulting OVA from applying Steps (1) - (4).
3. Use VMWare's ovftool to convert the OVA exported in (5) to a corresponding set of VMX files.
4. Rename the directory containing the VMX files to `output-vro-<variant>-<arch>-vmware-base` (e.g. for VRO 7.3 x86\_64, this is `output-vro-7.3-x86_64-vmware-base`)
5. Rename the VMX file inside the directory in (7) to `packer-vro-<variant>-<arch>-vmware-base.vmx` (e.g. for VRO 7.3 x86\_64, this is `packer-vro-7.3-x86_64-vmware-base.vmx`)
6. Ensure that the directory in (7) is placed in PACKER\_VM\_SRC\_DIR.

Note that with the above steps, we are basically building the "vmware base" image. For our other Linux platforms (e.g. Fedora 27), we have Packer templates to do this for us from an ISO file. However here, we are modifying a pre-built OVA. That is why Steps (4) - (6) consist of renaming the generated VMX files to fit with the existing naming convention used to denote artifacts resulting from a vmware-base built image (see the `source_path` variable in the vmware.vsphere.nocm).

Once the base VMX file has been created and is in the `PACKER_VM_SRC_DIR`, type the following command to build the image:
```
packer build -var-file=vars.json ../../common/vmware.vsphere.nocm.json
```

### The Boot Command

The boot command performs the following steps:
1. Sets the admin password to the `QA_ROOT_PASSWD_PLAIN` environment variable
2. Presses "Enter" to log-in to the VRO machine once the console menu pops-up
3. Logs in as admin (to open up a bash terminal)
4. Sets `PermitRootLogin yes` in `/etc/ssh/sshd_config`
5. Run `/sbin/chkconfig sshd on`
6. Run `/etc/init.d/sshd start`

^ The whole point of the boot command is to set the admin password, and then enable ssh so that Packer can provision the VM.

### VM settings


## Documentation

The Confluence Documentation for the process is at [Linux/Packer Imaging Process](https://confluence.puppetlabs.com/display/SRE/Linux+Image+Packer+Generation)

### Issues

Please open any issues within the CPR ( Community Package Repository ) project on the [Puppet Labs issue tracker](https://tickets.puppetlabs.com/browse/CPR).
