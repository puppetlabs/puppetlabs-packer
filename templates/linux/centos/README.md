# puppetlabs-packer

### About

This contains all of the var files required to build any of the templates in the
templates/linux/common directory for Centos platforms.

### Building

All templates must be built in the architecture directory.

## Centos 5.11/6.6
To build any template in the templates/linux/common directory for Centos 5.11/6.6, type:
```
packer build -var-file=../../common/vars.json -var-file=../common/vars.json -var-file=vars.json ../../../common/<template-file>
```

For example, if you want to build the vmware.vsphere.nocm template, type
```
packer build -var-file=../../common/vars.json -var-file=../common/vars.json -var-file=vars.json ../../../common/vmware.vsphere.nocm
```

## Centos 7.0/7.2
To build any template in the templates/linux/common directory for Centos 7.0/7.2, type:
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
