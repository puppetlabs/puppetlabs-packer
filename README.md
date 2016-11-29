# puppetlabs-packer

### About

This repository contains the [Packer](http://packer.io) and [Puppet](http://puppetlabs.com) manifests used to build boxes shipped to [Vagrant Cloud](http://vagrantcloud.com/puppetlabs).

### VM settings

* `root` password is set to `puppet`
* `vagrant` account uses the [Vagrant project's insecure public key](https://github.com/mitchellh/vagrant/tree/master/keys)

## Documentation

Confluence Documentation is available for the [Windows/Packer Imaging Process](https://confluence.puppetlabs.com/display/QE/Packer+Generation+of+Windows+Templates+for+VMPooler)

## Tests

Some very basic linting has been added to ensure files parse properly through packer. To run these tests do:

  `make test`

### Issues

Please open any issues within the CPR ( Community Package Repository ) project on the [Puppet Labs issue tracker](https://tickets.puppetlabs.com/browse/CPR).

