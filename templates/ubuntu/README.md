# puppetlabs-packer

### About

This contains all of the var files required to build any of the templates in the `templates/common` directory for Ubuntu platforms.

### Support Status

This repository includes OS platforms that are officially supported at Puppet and ones that are entirely maintained by the community. Packer templates include a `support_status` variable which indicates whether the template is puppet maintained vs. community maintained.

Puppet maintained Ubuntu versions include 14.04, 16.04, and 18.04. Any other versions of Ubuntu here are community maintained.

### Building

All templates must be built in the `<os_dist>/<variant>/<arch>` directory. Make sure that the environment variable PACKER\_VM\_OUT\_DIR is set so that Packer knows where to copy the build artifacts (it is common to set it to ".", the current `<os_dist>/<variant>/<arch>` directory). If you are building a template with a vmware-vmx builder, be sure to set the PACKER\_VM\_SRC\_DIR environment variable to the directory containing the directory containing the relevant vm files. It is common to set PACKER\_VM\_SRC\_DIR = PACKER\_VM\_OUT\_DIR to make it easy to build a vmware-vmx template from a previous vmware build.

To build any template in the `templates/common` directory, type:
```
packer build -var-file=../../common/vars.json -var-file=../common/vars.json -var-file=vars.json ../../../common/<template-file>
```

For example, if you want to build the vmware.vsphere.nocm template, type
```
packer build -var-file=../../common/vars.json -var-file=../common/vars.json -var-file=vars.json ../../../common/vmware.vsphere.nocm
```

### VM settings


## Documentation

The Confluence Documentation for the process is at [Linux/Packer Imaging Process](https://confluence.puppetlabs.com/display/SRE/Linux+Image+Packer+Generation)

### Issues

Please open any issues within the CPR ( Community Package Repository ) project on the [Puppet Labs issue tracker](https://tickets.puppetlabs.com/browse/CPR).
