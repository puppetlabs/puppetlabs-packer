# puppetlabs-packer

### About

This contains all of the var files required to build any of the templates in the
`templates/common` directory for Centos platforms.

### Building

All templates must be built in the `<os_dist>/<variant>/<arch>` directory. Make sure that the environment variable PACKER\_VM\_OUT\_DIR is set so that Packer knows where to copy the build artifacts (it is common to set it to ".", the current `<os_dist>/<variant>/<arch>` directory). If you are building a template with a vmware-vmx builder, be sure to set the PACKER\_VM\_SRC\_DIR environment variable to the directory containing the directory containing the relevant vm files. It is common to set PACKER\_VM\_SRC\_DIR = PACKER\_VM\_OUT\_DIR to make it easy to build a vmware-vmx template from a previous vmware build.

## Centos 5.11/6.8

The boot command for Centos < 7 is slightly different, so we have an additional var file to include in the build process.

To build any template in the `templates/common` directory for Centos 5.11/6.8, type:
```
packer build -var-file=../../common/vars.json -var-file=../common/vars.json -var-file=vars.json ../../../common/<template-file>
```

For example, if you want to build the vmware.vsphere.nocm template, type
```
packer build -var-file=../../common/vars.json -var-file=../common/vars.json -var-file=vars.json ../../../common/vmware.vsphere.nocm
```

## Centos 7.0/7.2
To build any template in the `templates/common` directory for Centos 7.0/7.2, type:
```
packer build -var-file=../../common/vars.json -var-file=vars.json ../../../common/<template-file>
```

For example, if you want to build the vmware.vsphere.nocm template, type
```
packer build -var-file=../../common/vars.json -var-file=vars.json ../../../common/vmware.vsphere.nocm
```

### VM settings


## Documentation

The Confluence Documentation for the process is at [Linux/Packer Imaging Process](https://confluence.puppetlabs.com/display/SRE/Linux+Image+Packer+Generation)

### Issues

Please open any issues within the CPR ( Community Package Repository ) project on the [Puppet Labs issue tracker](https://tickets.puppetlabs.com/browse/CPR).
