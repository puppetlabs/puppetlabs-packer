# puppetlabs-packer

### About

This contains the vmware.base image template for Debian platforms, as well as all of the var files required to build any of the other templates in the `templates/common` directory.

### Support Status

This repository includes OS platforms that are officially supported at Puppet and ones that are entirely maintained by the community. Packer templates include a `support_status` variable which indicates whether the template is puppet maintained vs. community maintained.

Puppet maintained Debian versions include 7.8, 8.2, and 9.0. Any other versions of Debian here are community maintained.

### Building

All templates must be built in the `<os_dist>/<variant>/<arch>` directory. Make sure that the environment variable PACKER\_VM\_OUT\_DIR is set so that Packer knows where to copy the build artifacts (it is common to set it to ".", the current `<os_dist>/<variant>/<arch>` directory). If you are building a template with a vmware-vmx builder, be sure to set the PACKER\_VM\_SRC\_DIR environment variable to the directory containing the directory containing the relevant vm files. It is common to set PACKER\_VM\_SRC\_DIR = PACKER\_VM\_OUT\_DIR to make it easy to build a vmware-vmx template from a previous vmware build.

To build the vmware.base image, type the following command:
```
packer build -var-file=vars.json ../../common/vmware.base.json
```

To build any of the other templates in the `templates/common` directory, type:
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

### Notes
The vmware.base image template for Debian is identical to the one in `templates/common`. The only reason there is a separate one here is because we could not figure out how to preseed Debian from the floppy disk -- the VM could not locate the preseed file despite it being inserted into the floppy disk by Packer. We want to preseed from floppy instead of an HTTP server, because in the latter case, Packer does not interpolate the {{ .HTTPIP }} and {{ .HTTPPort }} variables properly when substituting the boot command as a user variable instead of hard-coding it in the builder.

Thus, if someone manages to get our Debian platforms to boot from floppy, then the vmware.base template for Debian platforms is not needed, and they can instead use the one in `templates/common`.

Further, any updates to the `templates/common` vmware.base template should be applied to the vmware.base template in templates/debian/common.
