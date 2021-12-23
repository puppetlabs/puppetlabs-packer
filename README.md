# puppetlabs-packer

### About

This repository contains the [Packer](http://packer.io) and [Puppet](http://puppet.com) manifests used to build boxes shipped to VMware vsphere.

The Packer templates are organized under the following directory structure inside the root `templates` directory:
```
<os-distribution>/<variant>/<architecture>
```

1. `<os-distribution>` is the operating system distribution, for example `centos`
1. `<variant>` is the version or variant, e.g. `7.0` for `centos`, `10.13` for macOS, or `11.2` for solaris
1. `<architecture>` is the architecture, e.g. `x86_64` or `i386`

For brevity, `os_dist` refers to `os-distribution`, and `arch` refers to `architecture`. Each directory (`templates`, `templates/<os_dist>`, `templates/<os_dist>/<variant>`, or `templates/<os_dist>/<variant>/<arch>`) may or may not have a `common` directory in it. This directory can contain the following files:

* A specialized template that is specific to any sub-directories under that section.
* A `vars.json` file containing the required variables needed for other, parent `common` templates to build successfully.
* Other files, such as scripts, patches, or preseed files.

The intent for the `common` directory is to contain things that may be shared by some of the sub-directories.

The `<os_dist>/<variant>/<arch>` directory can contain (1) and (2), and technically (3), but we do not recommend (3) (as it’s highly likely that scripts, patches, or pressed files can apply to multiple architectures of a specific OS variant so they might as well be in their own `common` directory). There is one caveat. If a `common` or `<os_dist>/<variant>/<arch>` directory contains a particular template (e.g. like vmware.base.json) AND a `vars.json` file, then all variables for the template should be declared both in the template itself, and in any `vars.json` files found in sub-directories — the `vars.json` file in the current directory should not have variables for that specific template.

Here are the semantics behind each of the possible locations for a `common` directory:

* `templates/common` contains relevant templates and files for our *Linux-based* distributions. This was done because all of our os distributions, save for Macos, Windows, Solaris, are Linux-based.
* `<os-dist>/common` represents templates, variables and files that are shared by variants of a single OS distribution. For example for our Centos platforms, we have a `vars.json` file in `centos/common` that captures a common boot command.
* `<os-dist>/<variant>/common` represents templates, variables, and files specific to architectures of a variant of an OS distribution. For example for our Centos platforms, we have our pressed files in `centos/<variant>/common`, as well as some overriding variables for Centos 5.11 and Centos 6.6.

### SSH user accounts

* Windows: the Administrator password is `PackerAdmin`
* Solaris: the root password is `root`
* macOS: see the README under templates/macos
* For everything else, the root password is `puppet`

## Documentation

Confluence Documentation is available for the [Windows/Packer Imaging Process](https://confluence.puppetlabs.com/display/SRE/Packer+Generation+of+Windows+Templates+for+VMPooler) and the [Linux/Packer Imaging Process](https://confluence.puppetlabs.com/display/SRE/Linux+Image+Packer+Generation).

## Tests

Some very basic linting has been added to ensure files parse properly through packer. To run these tests do:

  `make test`

### Issues

Please open any issues within the CPR ( Community Package Repository ) project on the [Puppet issue tracker](https://tickets.puppetlabs.com/browse/CPR).

## Notes

This repository is currently undergoing a massive cleanup effort. We have decided to keep only the `vmware.base` and `vmware.vsphere.nocm` templates. If it turns out that this cleanup and refactoring has removed a template that you rely on (e.g. a virtual box or vagrant one), please checkout a version of the puppetlabs-packer repository at SHA `9babc323c862290d2eeb51d52fe133e564eba533` and accept our apologies in advance. We can correct these issues if we’re notified of them in a ticket.
