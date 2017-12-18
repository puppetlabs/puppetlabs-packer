# puppetlabs-packer

### About

This contains the vmware.base image template for Debian platforms, as well as all of the var files
required to build any of the other templates in the templates/linux/common directory.

Currently, only Debian 7.8, 8.2 and 9.0 are supported for both the 64-bit and 32-bit architectures.

### Building

All templates must be built in the architecture directory. Make sure that the environment variable PACKER\_VM\_OUT\_DIR is set so that Packer knows where to copy the build artifacts (it is common to set it to ".", the current [architecture] directory). If you are building a template with a vmware-vmx builder, be sure to set the PACKER\_VM\_SRC\_DIR environment variable to the directory containing the directory containing the relevant vm files. It is common to set PACKER\_VM\_SRC\_DIR = PACKER\_VM\_OUT\_DIR to make it easy to build a vmware-vmx template from a previous vmware build. 

To build the vmware.base image, type the following command:
```
packer build -var-file=vars.json ../../common/vmware.base.json
```

To build any of the other templates in the templates/linux/common directory, type:
```
packer build -var-file=../../common/vars.json -var-file=vars.json ../../../common/<template-file>
```

For example, if you want to build the vmware.vsphere.nocm template, type
```
packer build -var-file=../../common/vars.json -var-file=vars.json ../../../common/vmware.vsphere.nocm.json
```

### VM settings


## Documentation

The Confluence Documentation for the process is at [Linux/Packer Imaging Process](https://confluence.puppetlabs.com/display/SRE/Linux+Image+Packer+Generation)

### Issues

Please open any issues within the CPR ( Community Package Repository ) project on the [Puppet Labs issue tracker](https://tickets.puppetlabs.com/browse/CPR).
