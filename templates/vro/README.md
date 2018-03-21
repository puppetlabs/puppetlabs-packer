# puppetlabs-packer

### About

This contains the vmware.vsphere.nocm image template for VRO VMs, as well as all of the var files
required to build it.

Currently, only VRO 7.3 is supported for the 64-bit architecture.

### Building

All templates must be built in the `<os_dist>/<variant>/<arch>` directory. Make sure that the environment variable PACKER\_VM\_OUT\_DIR is set so that Packer knows where to copy the build artifacts (it is common to set it to ".", the current `<os_dist>/<variant>/<arch>` directory). If you are building a template with a vmware-vmx builder, be sure to set the PACKER\_VM\_SRC\_DIR environment variable to the directory containing the directory containing the relevant vm files. It is common to set PACKER\_VM\_SRC\_DIR = PACKER\_VM\_OUT\_DIR to make it easy to build a vmware-vmx template from a previous vmware build.

To build the vmware.vsphere.nocm image, you will need to manually create the VMWare base image from the downloaded, VMWare provided OVA. This is done via. the following steps:
1. Boot up the VM, and then configure the admin "root" password to be "puppet".
2. Go to `https://<vm-ip>:5480` (the VRO console), and login with the credentials created in (1).
3. Click on the "Admin" tab and check the following boxes:
   a. SSH service enabled
   b. Administrator SSH login enabled
4. Change the Network adapter settings for the VM to use a 'Shared Network' instead of 'Bridged Networking' 
5. Shutdown the VM, and then export the resulting OVA from applying Steps (1) - (4).
6. Use VMWare's ovftool to convert the OVA exported in (5) to a corresponding set of VMX files.
7. Rename the directory containing the VMX files to `output-vro-<variant>-<arch>-vmware-base` (e.g. for VRO 7.3 x86\_64, this is `output-vro-7.3-x86_64-vmware-base`)
8. Rename the VMX file inside the directory in (7) to `packer-vro-<variant>-<arch>-vmware-base.vmx` (e.g. for VRO 7.3 x86\_64, this is `packer-vro-7.3-x86_64-vmware-base.vmx`)
9. Ensure that the directory in (7) is placed in PACKER\_VM\_SRC\_DIR.


Note that with the above steps, we are basically building the "vmware base" image. For our other Linux platforms (e.g. Fedora 27), we have Packer templates to do this for us from an ISO file. However here, we are modifying a pre-built OVA. That is why Steps (7) - (9) consist of renaming the generated VMX files to fit with the existing naming convention used to denote artifacts resulting from a vmware-base built image (see the `source_path` variable in the vmware.vsphere.nocm).

Once the base VMX file has been created and is in the `PACKER_VM_SRC_DIR`, type the following command to build the image:
```
packer build -var-file=vars.json ../../common/vmware.vsphere.nocm.json
```

### VM settings


## Documentation

The Confluence Documentation for the process is at [Linux/Packer Imaging Process](https://confluence.puppetlabs.com/display/SRE/Linux+Image+Packer+Generation)

### Issues

Please open any issues within the CPR ( Community Package Repository ) project on the [Puppet Labs issue tracker](https://tickets.puppetlabs.com/browse/CPR).
