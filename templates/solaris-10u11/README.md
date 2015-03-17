Solaris 10
==========

Some notes about building Solaris 10:

  - This template was created to build Solaris 10 update 11, a.k.a Solaris 10 1/13, a.k.a 10u11.
    Newer and older versions may or may not work.
    The installation media, `sol-10-u11-ga-x86-dvd.iso`, is not freely available but may be downloaded from Oracle after registering for a free account.

  - The VM *must* have at least 768 MB of memory.
    Otherwise, the installer will silently fail to start.
    Adding more that 942 MB of memory will cause the installer to boot in 64 bit mode and silently fail to start.

  - Details concerning the workings of Solaris 10u11 can be found in the [Oracle Library][solaris 10u11 library].
    Of specific interest:

      - The [list of available packages on the install cdrom][solaris 10u11 packages].

      - The [JumpStart Documentation][solaris 10u11 jumpstart].

[solaris 10u11 library]: http://docs.oracle.com/cd/E26505_01/html/E27063/index.html
[solaris 10u11 packages]: http://docs.oracle.com/cd/E26505_01/html/E27063/index.html
[solaris 10u11 jumpstart]: http://docs.oracle.com/cd/E26505_01/html/E28039/index.html
