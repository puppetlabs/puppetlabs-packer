Solaris 11
==========

Some notes about building Solaris 11 under packer.
Parts of this build, notably the boot command and automated install manifests, have been adapted from the [Chef Bento project][bento-solaris-11].

The Boot Command
----------------

The boot command needs some explanation because it is truly an epic hack.
The command is long and does a lot more than any boot command rightfully should --- such as executing a pile of shell commands.
On the other hand, all Packer boot commands for Solaris 11 that I have seen so far pull similarly crazy shenanigans.

Here is the boot command in its entirety:

```json
[
  "e<wait>",
  "<down><down><down><down><down><wait>",
  "<end><wait>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><wait>",
  "false<wait>",
  "<f10><wait>",
  "<wait10><wait10><wait10><wait10><wait10><wait10>",
  "<wait10><wait10><wait10><wait10><wait10><wait10>",
  "<wait10><wait10><wait10><wait10><wait10><wait10>",
  "root<enter><wait><wait>",
  "solaris<enter><wait10>",

  "<enter>while (true);",
  "do test -f /a/etc/ssh/sshd_config && perl -pi -e 's/PermitRootLogin no/PermitRootLogin yes/' /a/etc/ssh/sshd_config && break;",
  "sleep 10;",
  "done &<enter><wait>",

  "<enter>while (true);",
  "do grep \"You may wish to reboot\" \"/var/svc/log/application-auto-installer:default.log\" 2> /dev/null && reboot && break;",
  "sleep 10;",
  "done &<enter><wait>",

  "curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/ai.xml -o /system/volatile/ai.xml<enter><wait>",
  "mkdir /system/volatile/profile<enter><wait>",
  "curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/profile.xml -o /system/volatile/profile/profile.xml<enter><wait>",
  "svcadm enable svc:/application/auto-installer:default<enter><wait>",
  "<enter><wait10><wait><wait>",
  "<enter><wait>",
  "tail -f /system/volatile/install_log<enter><wait>"
]
```

The first chunk exits to the GRUB shell and boots the system with automated installation disabled.
The second chunk waits for the system to come up and logs in with the default username and password of `root` and `solaris`.
The next two chunks set up two background loops:

  - One loop waits for installation to proceed to a point where SSHD configuration is laid down and then enables root login for Packer.
    Note that `/a` is the mountpoint where the Solaris 11 system will be installed and it will be unmounted at the end of installation.

  - The second loop waits for installation to finish and than reboots the system out of the installer and into the new OS.

The final chunk pulls down the XML configuration for Solaris 11 Automated Installation and kicks off the install process and then tails the progress log.
The XML definitions are pretty stock except the following differences:

  - `profile.xml` sets up `root` as a normal user account instead of a "role" (whatever a role is, it's not something that packer can log into).


Other Notes
-----------

The VM _must_ have more than 768 MB of memory during install since it is running from a RAM disk.
Memory size is currently set at 1536 MB, but not sure if that is the lower limit.

  [bento-solaris-11]: https://github.com/opscode/bento/blob/94c618231e40a7e8e69774ed163eea46e62abe37/packer/solaris-11-x86.json
