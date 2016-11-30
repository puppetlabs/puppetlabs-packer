# puppetlabs-packer

### About

This is the Windows 10 Packer Template

### Build notes

The Cumulative updates and associated component cleanup (Dism /StartComponentCleanup) appear to have quite a few issues that prevent building on the jenkins-imaging build hosts.
So a revised Slipstream procedure has been put in place to specify and download the latest Cumulative Update and a preceding critical fix as MSU from the [Microsoft Update Catalog](http://www.catalog.update.microsoft.com/Home.ASPX)
These are added as packages (slipstreamed) to the offline image. The Cleanup Component operation is also done before the ISO Source for the base build is produced.
The Clean-Dism procedure is not used during the actual base build as it only yields a very small space improvement, whereas, if left in place, it tends to affect the reliability of the build.

### VM settings


## Documentation

The Confluence Documentation for the process is at [Windows/Packer Imaging Process](https://confluence.puppetlabs.com/display/QE/Packer+Generation+of+Windows+Templates+for+VMPooler)


### Issues

Please open any issues within the CPR ( Community Package Repository ) project on the [Puppet Labs issue tracker](https://tickets.puppetlabs.com/browse/CPR).
