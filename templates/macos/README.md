
# puppetlabs-packer: macOS templates

## Support Status

This repository includes OS platforms that are officially supported at Puppet and ones that are entirely maintained by the community. Packer templates include a `support_status` variable which indicates whether the template is puppet maintained vs. community maintained.

## Prerequisites

Imaging for macOS has become particularly difficult after the release of 10.12.4. At this point, to build one of these templates, **you must have:**

- Access to Puppet's internal OS image mirrors (to download the customized 10.12 ESD image)
- The common password for Puppet's pooler VMs (this is built into the 10.12 ESD image)

See Background, below, for more information.

## Building

### 10.15 Catalina

The macOS 10.15 image uses a bootable `.iso` file generated from the `Install macOS
Catalina.app` from the App Store.

Most of the installation (until the desktop screen shows) is automated with boot
command keystrokes. In broad terms, this is what the `boot_command` does

1. English language is selected in the installer
2. Opens a Terminal session, inputs the following commands:
    - `diskutil eraseDisk APFS 'Macintosh HD' /dev/disk0` - erases the installation disk
    - `until '/Install macOS Catalina.app/Contents/Resources/startosinstall'
      --agreetolicense --volume '/Volumes/Macintosh HD'; do echo 'trying
      again...'; done` - runs the non-interactive installer with a simple guard
      (it fails from time to time when getting Recovery Information from Apple)
3. The system then reboots and continues the installation, while the boot command
   waits for 50 minutes
4. Configuration resumes, goes through region and language settings...
5. Network configuration is sometimes prompted (this is not scripted in the boot
   command since it doesn't happen all the time, still trying to figure this
   out)
6. Privacy, Transfer, iCloud, License Agreement, Account Creation (user: osx,
   password: puppet), Screen Time, Siri, Theme are configured
7. Desktop screen shows up, which means installation is done

After reaching the desktop screen, the boot command waits for another 10
minutes, then switches context to Packer which (by default) waits for an IP from
the guest machine for 30 minutes. That's to give us time to set up VMware Tools
so the machine becomes reachable over SSH:

1. Open a Terminal (Launchpad -> Terminal)
2. Change the `root` password to puppet (`sudo passwd root`)
3. Elevate (`sudo su - root`)
4. Edit `/etc/ssh/sshd_config`, uncomment `PermitRootLogin` and set it to `yes`
5. Give Full Disk Access to Terminal (System Preferences -> Security & Privacy
   -> Privacy -> Full Disk Access)
6. Provided the VMware Tools image is mounted, you can install it with
   `installer -pkg '/Volumes/VMware Tools/Install VMware
   Tools.app/Contents/Resources/VMware Tools.pkg' -target / -verbose`
7. The installer will probably fail (due to Apple blocking VMware's system
   extension), you need to open the Security & Privacy panel again, go to
   General and click Allow, then run the installer again
8. Install the XCode Command Line tools by running `xcode-select --install`;
   this is an interactive process that can only be done via the user interface.
9. After a reboot, the machine should have an IP and you should have mouse acceleration
10. Execute `systemsetup -setremotelogin on` to start the SSH server (this does
    not persist between reboots, so you might need to start it again if you
    rebooted sometime in the process)

### 11.2 Big Sur

The Big Sur follows the same process as Catalina, but the `boot_command` is
reduced to the first 3 steps, and extends the wait time to 80 minutes.

After the installation, the machine will need to be configured manually (steps
4-7), along with the VMWare Tools and XCode setup.

### 12 Monterey

The macOS 12 Monterey build process is identical to that of Big Sur.

## Background

Previously, the creation of packer templates for macOS involved the following steps:

1. Download an official "Install macOS \<version\>" installer from the App Store
2. Create a customization pkg file that:
    - Sets up an SSH user account, and
    - Runs a script which:
        - enables SSH,
        - adds the SSH user to sudoers,
        - bypasses annoyances like Siri and iCloud setup dialogues, etc.
3. Use the ESD and Base System images from the official installer to build a customized autoinstaller image that:
    - Sets appropriate values for the autoinstall process (e.g. language and target disk), and
    - Installs the customization pkg after the regular install process completes.
4. Once this autoinstaller is created, use it as the basis for the packer template, which will perform other setup tasks like installing vmware tools, adding authorized ssh keys, and setting up GUI autologin for the SSH user.

Variants of this process had been used for several years by lots of community projects (for example [timsutton/osx-vm-templates](https://github.com/timsutton/osx-vm-templates)). The 10.12 ESD image referred to in our 10.12 and 10.13 templates was created this way.

**From macOS 10.12.4 onward**, this process no longer works, because any additional pkg files built into the installer must now be signed by Apple in order for the process to proceed. Simply signing the customization pkg with an Apple developer ID certificate does not seem to be sufficient. A few alternative methods have been proposed for specific use cases, but nothing has emerged as a broadly reliable solution.

For 10.12, we had created a working, customized installer image before this restriction went into effect (the 10.12 ESD mentioned in these templates); We still use that installer, then we apply system updates after the install process is finished.

For the 10.13 template we do not have a working customized installer image; Instead, we install 10.12 using our customized installer, then upgrade the system to 10.13 using its official installer.
