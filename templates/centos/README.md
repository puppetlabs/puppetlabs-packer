# refactored templates for centos 6

Will incorperate other vesions soon,  Still POC

Only for libvirt yet.  Will try other builders soon

Important vars are set mandatory.

This can be checked with the following command:

```
packer inspect libvirt-base.json
```

adopt above command to wanted template

one need to build the base template

Optional variables should be used in the -var option.


keep in mind that the ordering matters for the \*variables\* json files
when used with the -var-file option,
the -var file option will overule everything

Vars that shoul be used with -var option :

* headless (defaults to true)
* output_dir (defaults to '/opt/output'

all boxes build an come up properly,

Command to build a box :

```
/bin/packer build -var-file=builder.variables.json -var-file=provisioner.variables.json -var-file="i386.centos-6.8.variables.json" -var "iso_url=/data/johan/iso_images/CentOS-6.8-i386-bin-DVD1.iso" libvirt.base.json
~/bin/packer build -var-file=builder.variables.json -var-file=provisioner.variables.json -var-file="i386.centos-6.8.variables.json" libvirt.nocm.json
~/bin/packer build -var-file=builder.variables.json -var-file=provisioner.variables.json -var-file="i386.centos-6.8.variables.json" libvirt.puppet.json
```

## testing

```
  for i in `ls *centos*.json`
  do
    ~/bin/packer validate --syntax-only -var-file=builder.variables.json -var-file=provisioner.variables.json -var-file=$i libvirt.base.json
  done
```

# TODO

* looking for a proper dir structure ?
* write decentt docs
* add virtualbox, vmware and more
* look how to add version 5 (during build, VM does not power recycle properly)
* ......

