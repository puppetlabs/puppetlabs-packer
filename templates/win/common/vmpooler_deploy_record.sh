# This is a record of the shell commands using platform-ci-utils to update
# windows/vmpooler images through the api.

# Please add the current deploy commands here, check them and then execute
# them on a host with the platform-ci-utils command installed.
# It is recommended that you execute these command in small batches to give
# pooler time to clone and ready the new machines.
# Keeping a log open on vmpooler is also a really good idea.


# November 2020 vmpooler updates

# Windows 10 Odd templates
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-pro-x86_64:templates/netapp/acceptance2/win-10-pro-x86_64-20201113 \
            win-10-1511-x86_64:templates/netapp/acceptance2/win-10-1511-x86_64-20201113 \
            win-10-1607-x86_64:templates/netapp/acceptance2/win-10-1607-x86_64-20201113 \
            win-10-1809-x86_64:templates/netapp/acceptance2/win-10-1809-x86_64-20201113
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-pro-x86_64-pixa4:templates/netapp/acceptance4/win-10-pro-x86_64-20201113 \
            win-10-1511-x86_64-pixa4:templates/netapp/acceptance4/win-10-1511-x86_64-20201113 \
            win-10-1607-x86_64-pixa4:templates/netapp/acceptance4/win-10-1607-x86_64-20201113 \
            win-10-1809-x86_64-pixa4:templates/netapp/acceptance4/win-10-1809-x86_64-20201113

# Windows 10 Main Ent 
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-ent-i386:templates/netapp/acceptance2/win-10-ent-i386-20201113 \
            win-10-ent-x86_64:templates/netapp/acceptance2/win-10-ent-x86_64-20201113
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-ent-i386-pixa4:templates/netapp/acceptance4/win-10-ent-i386-20201113 \
            win-10-ent-x86_64-pixa4:templates/netapp/acceptance4/win-10-ent-x86_64-20201113

# Windows 10 Next Release
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-next-i386:templates/netapp/acceptance2/win-10-next-i386-20201113 \
            win-10-next-x86_64:templates/netapp/acceptance2/win-10-next-x86_64-20201113
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-next-i386-pixa4:templates/netapp/acceptance4/win-10-next-i386-20201113 \
            win-10-next-x86_64-pixa4:templates/netapp/acceptance4/win-10-next-x86_64-20201113

# Windows 81
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
            --pools=win-81-x86_64:templates/netapp/acceptance2/win-81-x86_64-20201113
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
            --pools=win-81-x86_64-pixa4:templates/netapp/acceptance4/win-81-x86_64-20201113


# Windows 2012r2 Primary 
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012r2-x86_64:templates/netapp/acceptance2/win-2012r2-x86_64-20201113
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012r2-x86_64-pixa4:templates/netapp/acceptance4/win-2012r2-x86_64-20201113

# Windows 2012/2012r2 remainder platforms
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012-x86_64:templates/netapp/acceptance2/win-2012-x86_64-20201113 \
            win-2012r2-core-x86_64:templates/netapp/acceptance2/win-2012r2-core-x86_64-20201113 \
            win-2012r2-fips-x86_64:templates/netapp/acceptance2/win-2012r2-fips-x86_64-20201113 \
            win-2012r2-wmf5-x86_64:templates/netapp/acceptance2/win-2012r2-wmf5-x86_64-20201113
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012-x86_64-pixa4:templates/netapp/acceptance4/win-2012-x86_64-20201113 \
            win-2012r2-core-x86_64-pixa4:templates/netapp/acceptance4/win-2012r2-core-x86_64-20201113 \
            win-2012r2-fips-x86_64-pixa4:templates/netapp/acceptance4/win-2012r2-fips-x86_64-20201113 \
            win-2012r2-wmf5-x86_64-pixa4:templates/netapp/acceptance4/win-2012r2-wmf5-x86_64-20201113
#....
# Windows 2016
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2016-core-x86_64:templates/netapp/acceptance2/win-2016-core-x86_64-20201113 \
            win-2016-x86_64:templates/netapp/acceptance2/win-2016-x86_64-20201113 \
            win-2016-x86_64-ipv6:templates/netapp/acceptance2/win-2016-x86_64-20201113-ipv6

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2016-core-x86_64-pixa4:templates/netapp/acceptance4/win-2016-core-x86_64-20201113 \
            win-2016-x86_64-pixa4:templates/netapp/acceptance4/win-2016-x86_64-20201113 \
            win-2016-x86_64-ipv6-pixa4:templates/netapp/acceptance4/win-2016-x86_64-20201113-ipv6

# Windows 2019
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2019-core-x86_64:templates/netapp/acceptance2/win-2019-core-x86_64-20201113 \
            win-2019-x86_64:templates/netapp/acceptance2/win-2019-x86_64-20201113 \
            win-2019-ja-x86_64:templates/netapp/acceptance2/win-2019-ja-x86_64-20201113 \
            win-2019-fr-x86_64:templates/netapp/acceptance2/win-2019-fr-x86_64-20201113

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2019-core-x86_64-pixa4:templates/netapp/acceptance4/win-2019-core-x86_64-20201113 \
            win-2019-x86_64-pixa4:templates/netapp/acceptance4/win-2019-x86_64-20201113 \
            win-2019-ja-x86_64-pixa4:templates/netapp/acceptance4/win-2019-ja-x86_64-20201113 \
            win-2019-fr-x86_64-pixa4:templates/netapp/acceptance4/win-2019-fr-x86_64-20201113

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2019-wslssh-x86_64-pixa4:templates/netapp/acceptance4/win-2019-wslssh-x86_64-20200813

#Done

# PR Update command:

platform-ci-utils imaging-update-pools-in-pl-modules \
    --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20201113 \
            win-10-1511-x86_64:templates/win-10-1511-x86_64-20201113 \
            win-10-1607-x86_64:templates/win-10-1607-x86_64-20201113 \
            win-10-1809-x86_64:templates/win-10-1809-x86_64-20201113 \
            win-10-pro-x86_64-pixa4:templates/acceptance4/win-10-pro-x86_64-20201113 \
            win-10-1511-x86_64-pixa4:templates/acceptance4/win-10-1511-x86_64-20201113 \
            win-10-1607-x86_64-pixa4:templates/acceptance4/win-10-1607-x86_64-20201113 \
            win-10-1809-x86_64-pixa4:templates/acceptance4/win-10-1809-x86_64-20201113 \
            win-10-ent-i386:templates/win-10-ent-i386-20201113 \
            win-10-ent-x86_64:templates/win-10-ent-x86_64-20201113 \
            win-10-ent-i386-pixa4:templates/acceptance4/win-10-ent-i386-20201113 \
            win-10-ent-x86_64-pixa4:templates/acceptance4/win-10-ent-x86_64-20201113 \
            win-10-next-i386:templates/win-10-next-i386-20201113 \
            win-10-next-x86_64:templates/win-10-next-x86_64-20201113 \
            win-10-next-i386-pixa4:templates/acceptance4/win-10-next-i386-20201113 \
            win-10-next-x86_64-pixa4:templates/acceptance4/win-10-next-x86_64-20201113 \
            win-81-x86_64:templates/win-81-x86_64-20201113 \
            win-81-x86_64-pixa4:templates/acceptance4/win-81-x86_64-20201113 \
            win-2012r2-x86_64:templates/win-2012r2-x86_64-20201113 \
            win-2012r2-x86_64-pixa4:templates/acceptance4/win-2012r2-x86_64-20201113 \
            win-2012-x86_64:templates/win-2012-x86_64-20201113 \
            win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20201113 \
            win-2012r2-fips-x86_64:templates/win-2012r2-fips-x86_64-20201113 \
            win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20201113 \
            win-2012-x86_64-pixa4:templates/acceptance4/win-2012-x86_64-20201113 \
            win-2012r2-core-x86_64-pixa4:templates/acceptance4/win-2012r2-core-x86_64-20201113 \
            win-2012r2-fips-x86_64-pixa4:templates/acceptance4/win-2012r2-fips-x86_64-20201113 \
            win-2012r2-wmf5-x86_64-pixa4:templates/acceptance4/win-2012r2-wmf5-x86_64-20201113 \
            win-2016-core-x86_64:templates/win-2016-core-x86_64-20201113 \
            win-2016-x86_64:templates/win-2016-x86_64-20201113 \
            win-2016-x86_64-ipv6:templates/win-2016-x86_64-20201113-ipv6 \
            win-2016-core-x86_64-pixa4:templates/acceptance4/win-2016-core-x86_64-20201113 \
            win-2016-x86_64-pixa4:templates/acceptance4/win-2016-x86_64-20201113 \
            win-2016-x86_64-ipv6-pixa4:templates/acceptance4/win-2016-x86_64-20201113-ipv6 \
            win-2019-core-x86_64:templates/win-2019-core-x86_64-20201113 \
            win-2019-x86_64:templates/win-2019-x86_64-20201113 \
            win-2019-ja-x86_64:templates/win-2019-ja-x86_64-20201113 \
            win-2019-fr-x86_64:templates/win-2019-fr-x86_64-20201113 \
            win-2019-core-x86_64-pixa4:templates/acceptance4/win-2019-core-x86_64-20201113 \
            win-2019-x86_64-pixa4:templates/acceptance4/win-2019-x86_64-20201113 \
            win-2019-ja-x86_64-pixa4:templates/acceptance4/win-2019-ja-x86_64-20201113 \
            win-2019-fr-x86_64-pixa4:templates/acceptance4/win-2019-fr-x86_64-20201113







# ######################################################################################

# August 2020 vmpooler updates

# Windows 10 Odd templates
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20200813 \
            win-10-1511-x86_64:templates/win-10-1511-x86_64-20200813 \
            win-10-1607-x86_64:templates/win-10-1607-x86_64-20200813 \
            win-10-1809-x86_64:templates/win-10-1809-x86_64-20200813
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-pro-x86_64-pixa4:templates/acceptance4/win-10-pro-x86_64-20200813 \
            win-10-1511-x86_64-pixa4:templates/acceptance4/win-10-1511-x86_64-20200813 \
            win-10-1607-x86_64-pixa4:templates/acceptance4/win-10-1607-x86_64-20200813 \
            win-10-1809-x86_64-pixa4:templates/acceptance4/win-10-1809-x86_64-20200813

# Windows 10 Main Ent 
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-ent-i386:templates/win-10-ent-i386-20200813 \
            win-10-ent-x86_64:templates/win-10-ent-x86_64-20200813
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-ent-i386-pixa4:templates/acceptance4/win-10-ent-i386-20200813 \
            win-10-ent-x86_64-pixa4:templates/acceptance4/win-10-ent-x86_64-20200813

# Windows 10 Next Release
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-next-i386:templates/win-10-next-i386-20200813 \
            win-10-next-x86_64:templates/win-10-next-x86_64-20200813
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-next-i386-pixa4:templates/acceptance4/win-10-next-i386-20200813 \
            win-10-next-x86_64-pixa4:templates/acceptance4/win-10-next-x86_64-20200813

# Windows 81
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
            --pools=win-81-x86_64:templates/win-81-x86_64-20200813
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
            --pools=win-81-x86_64-pixa4:templates/acceptance4/win-81-x86_64-20200813


# Windows 2012r2 Primary 
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012r2-x86_64:templates/win-2012r2-x86_64-20200813
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012r2-x86_64-pixa4:templates/acceptance4/win-2012r2-x86_64-20200813

# Windows 2012/2012r2 remainder platforms
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012-x86_64:templates/win-2012-x86_64-20200813 \
            win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20200813 \
            win-2012r2-fips-x86_64:templates/win-2012r2-fips-x86_64-20200813 \
            win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20200813
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012-x86_64-pixa4:templates/acceptance4/win-2012-x86_64-20200813 \
            win-2012r2-core-x86_64-pixa4:templates/acceptance4/win-2012r2-core-x86_64-20200813 \
            win-2012r2-fips-x86_64-pixa4:templates/acceptance4/win-2012r2-fips-x86_64-20200813 \
            win-2012r2-wmf5-x86_64-pixa4:templates/acceptance4/win-2012r2-wmf5-x86_64-20200813

# Windows 2016
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2016-core-x86_64:templates/win-2016-core-x86_64-20200813 \
            win-2016-x86_64:templates/win-2016-x86_64-20200813 \
            win-2016-x86_64-ipv6:templates/win-2016-x86_64-20200813-ipv6

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2016-core-x86_64-pixa4:templates/acceptance4/win-2016-core-x86_64-20200813 \
            win-2016-x86_64-pixa4:templates/acceptance4/win-2016-x86_64-20200813 \
            win-2016-x86_64-ipv6-pixa4:templates/acceptance4/win-2016-x86_64-20200813-ipv6

# Windows 2019
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2019-core-x86_64:templates/win-2019-core-x86_64-20200813 \
            win-2019-x86_64:templates/win-2019-x86_64-20200813 \
            win-2019-wslssh-x86_64:templates/win-2019-wslssh-x86_64-20200813 \
            win-2019-ja-x86_64:templates/win-2019-ja-x86_64-20200813 \
            win-2019-fr-x86_64:templates/win-2019-fr-x86_64-20200813

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2019-core-x86_64-pixa4:templates/acceptance4/win-2019-core-x86_64-20200813 \
            win-2019-x86_64-pixa4:templates/acceptance4/win-2019-x86_64-20200813 \
            win-2019-wslssh-x86_64-pixa4:templates/acceptance4/win-2019-wslssh-x86_64-20200813 \
            win-2019-ja-x86_64-pixa4:templates/acceptance4/win-2019-ja-x86_64-20200813 \
            win-2019-fr-x86_64-pixa4:templates/acceptance4/win-2019-fr-x86_64-20200813
#Done

# PR Update command:

platform-ci-utils imaging-update-pools-in-pl-modules \
    --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20200813 \
            win-10-1511-x86_64:templates/win-10-1511-x86_64-20200813 \
            win-10-1607-x86_64:templates/win-10-1607-x86_64-20200813 \
            win-10-1809-x86_64:templates/win-10-1809-x86_64-20200813 \
            win-10-pro-x86_64-pixa4:templates/acceptance4/win-10-pro-x86_64-20200813 \
            win-10-1511-x86_64-pixa4:templates/acceptance4/win-10-1511-x86_64-20200813 \
            win-10-1607-x86_64-pixa4:templates/acceptance4/win-10-1607-x86_64-20200813 \
            win-10-1809-x86_64-pixa4:templates/acceptance4/win-10-1809-x86_64-20200813 \
            win-10-ent-i386:templates/win-10-ent-i386-20200813 \
            win-10-ent-x86_64:templates/win-10-ent-x86_64-20200813 \
            win-10-ent-i386-pixa4:templates/acceptance4/win-10-ent-i386-20200813 \
            win-10-ent-x86_64-pixa4:templates/acceptance4/win-10-ent-x86_64-20200813 \
            win-10-next-i386:templates/win-10-next-i386-20200813 \
            win-10-next-x86_64:templates/win-10-next-x86_64-20200813 \
            win-10-next-i386-pixa4:templates/acceptance4/win-10-next-i386-20200813 \
            win-10-next-x86_64-pixa4:templates/acceptance4/win-10-next-x86_64-20200813 \
            win-81-x86_64:templates/win-81-x86_64-20200813 \
            win-81-x86_64-pixa4:templates/acceptance4/win-81-x86_64-20200813 \
            win-2012r2-x86_64:templates/win-2012r2-x86_64-20200813 \
            win-2012r2-x86_64-pixa4:templates/acceptance4/win-2012r2-x86_64-20200813 \
            win-2012-x86_64:templates/win-2012-x86_64-20200813 \
            win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20200813 \
            win-2012r2-fips-x86_64:templates/win-2012r2-fips-x86_64-20200813 \
            win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20200813 \
            win-2012-x86_64-pixa4:templates/acceptance4/win-2012-x86_64-20200813 \
            win-2012r2-core-x86_64-pixa4:templates/acceptance4/win-2012r2-core-x86_64-20200813 \
            win-2012r2-fips-x86_64-pixa4:templates/acceptance4/win-2012r2-fips-x86_64-20200813 \
            win-2012r2-wmf5-x86_64-pixa4:templates/acceptance4/win-2012r2-wmf5-x86_64-20200813 \
            win-2016-core-x86_64:templates/win-2016-core-x86_64-20200813 \
            win-2016-x86_64:templates/win-2016-x86_64-20200813 \
            win-2016-x86_64-ipv6:templates/win-2016-x86_64-20200813-ipv6 \
            win-2016-core-x86_64-pixa4:templates/acceptance4/win-2016-core-x86_64-20200813 \
            win-2016-x86_64-pixa4:templates/acceptance4/win-2016-x86_64-20200813 \
            win-2016-x86_64-ipv6-pixa4:templates/acceptance4/win-2016-x86_64-20200813-ipv6 \
            win-2019-core-x86_64:templates/win-2019-core-x86_64-20200813 \
            win-2019-x86_64:templates/win-2019-x86_64-20200813 \
            win-2019-wslssh-x86_64:templates/win-2019-wslssh-x86_64-20200813 \
            win-2019-ja-x86_64:templates/win-2019-ja-x86_64-20200813 \
            win-2019-fr-x86_64:templates/win-2019-fr-x86_64-20200813 \
            win-2019-core-x86_64-pixa4:templates/acceptance4/win-2019-core-x86_64-20200813 \
            win-2019-x86_64-pixa4:templates/acceptance4/win-2019-x86_64-20200813 \
            win-2019-wslssh-x86_64-pixa4:templates/acceptance4/win-2019-wslssh-x86_64-20200813 \
            win-2019-ja-x86_64-pixa4:templates/acceptance4/win-2019-ja-x86_64-20200813 \
            win-2019-fr-x86_64-pixa4:templates/acceptance4/win-2019-fr-x86_64-20200813







# January 2020 vmpooler updates

# Windows 10 Odd templates
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20200121 \
            win-10-1511-x86_64:templates/win-10-1511-x86_64-20200121 \
            win-10-1607-x86_64:templates/win-10-1607-x86_64-20200121 \
            win-10-1809-x86_64:templates/win-10-1809-x86_64-20200121
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-pro-x86_64-pixa4:templates/acceptance4/win-10-pro-x86_64-20200121 \
            win-10-1511-x86_64-pixa4:templates/acceptance4/win-10-1511-x86_64-20200121 \
            win-10-1607-x86_64-pixa4:templates/acceptance4/win-10-1607-x86_64-20200121 \
            win-10-1809-x86_64-pixa4:templates/acceptance4/win-10-1809-x86_64-20200121

# Windows 10 Main Ent 
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-ent-i386:templates/win-10-ent-i386-20200121 \
            win-10-ent-x86_64:templates/win-10-ent-x86_64-20200121
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-ent-i386-pixa4:templates/acceptance4/win-10-ent-i386-20200121 \
            win-10-ent-x86_64-pixa4:templates/acceptance4/win-10-ent-x86_64-20200121

# Windows 10 Next Release
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-next-i386:templates/win-10-next-i386-20200121 \
            win-10-next-x86_64:templates/win-10-next-x86_64-20200121
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-next-i386-pixa4:templates/acceptance4/win-10-next-i386-20200121 \
            win-10-next-x86_64-pixa4:templates/acceptance4/win-10-next-x86_64-20200121

# Windows 7/81
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-7-x86_64:templates/win-7-x86_64-20200121 \
            win-81-x86_64:templates/win-81-x86_64-20200121
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-7-x86_64-pixa4:templates/acceptance4/win-7-x86_64-20200121 \
            win-81-x86_64-pixa4:templates/acceptance4/win-81-x86_64-20200121

# Windows 2008/2008r2
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2008-x86_64:templates/win-2008-x86_64-20200121 \
            win-2008r2-x86_64:templates/win-2008r2-x86_64-20200121 
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2008-x86_64-pixa4:templates/acceptance4/win-2008-x86_64-20200121 \
            win-2008r2-x86_64-pixa4:templates/acceptance4/win-2008r2-x86_64-20200121

# Windows 2012r2 Primary 
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012r2-x86_64:templates/win-2012r2-x86_64-20200121
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012r2-x86_64-pixa4:templates/acceptance4/win-2012r2-x86_64-20200121

# Windows 2012/2012r2 remainder platforms
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012-x86_64:templates/win-2012-x86_64-20200121 \
            win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20200121 \
            win-2012r2-fips-x86_64:templates/win-2012r2-fips-x86_64-20200121 \
            win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20200121
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012-x86_64-pixa4:templates/acceptance4/win-2012-x86_64-20200121 \
            win-2012r2-core-x86_64-pixa4:templates/acceptance4/win-2012r2-core-x86_64-20200121 \
            win-2012r2-fips-x86_64-pixa4:templates/acceptance4/win-2012r2-fips-x86_64-20200121 \
            win-2012r2-wmf5-x86_64-pixa4:templates/acceptance4/win-2012r2-wmf5-x86_64-20200121

# Windows 2016
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2016-core-x86_64:templates/win-2016-core-x86_64-20200121 \
            win-2016-x86_64:templates/win-2016-x86_64-20200121 \
            win-2016-x86_64-ipv6:templates/win-2016-x86_64-20200121-ipv6

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2016-core-x86_64-pixa4:templates/acceptance4/win-2016-core-x86_64-20200121 \
            win-2016-x86_64-pixa4:templates/acceptance4/win-2016-x86_64-20200121 \
            win-2016-x86_64-ipv6-pixa4:templates/acceptance4/win-2016-x86_64-20200121-ipv6

# Windows 2019
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2019-core-x86_64:templates/win-2019-core-x86_64-20200121 \
            win-2019-x86_64:templates/win-2019-x86_64-20200121 \
            win-2019-wslssh-x86_64:templates/win-2019-wslssh-x86_64-20200121 \
            win-2019-ja-x86_64:templates/win-2019-ja-x86_64-20200121 \
            win-2019-fr-x86_64:templates/win-2019-fr-x86_64-20200121

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2019-core-x86_64-pixa4:templates/acceptance4/win-2019-core-x86_64-20200121 \
            win-2019-x86_64-pixa4:templates/acceptance4/win-2019-x86_64-20200121 \
            win-2019-wslssh-x86_64-pixa4:templates/acceptance4/win-2019-wslssh-x86_64-20200121 \
            win-2019-ja-x86_64-pixa4:templates/acceptance4/win-2019-ja-x86_64-20200121 \
            win-2019-fr-x86_64-pixa4:templates/acceptance4/win-2019-fr-x86_64-20200121
#Done



# October 2019 vmpooler updates

# Windows 10 Odd templates
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20191011 \
            win-7-wmf5-x86_64:templates/win-7-wmf5-x86_64-20191011 \
            win-10-1511-x86_64:templates/win-10-1511-x86_64-20191011 \
            win-10-1607-x86_64:templates/win-10-1607-x86_64-20191011 \
            win-10-1809-x86_64:templates/win-10-1809-x86_64-20191011
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-pro-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-10-pro-x86_64-20191011 \
            win-7-wmf5-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-7-wmf5-x86_64-20191011 \
            win-10-1511-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-10-1511-x86_64-20191011 \
            win-10-1607-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-10-1607-x86_64-20191011 \
            win-10-1809-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-10-1809-x86_64-20191011

# Windows 10 Main Ent 
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-ent-i386:templates/win-10-ent-i386-20191011 \
            win-10-ent-x86_64:templates/win-10-ent-x86_64-20191011
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-ent-i386-pixa3:templates/tintri-pix-2-vmpooler/win-10-ent-i386-20191011 \
            win-10-ent-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-10-ent-x86_64-20191011

# Windows 10 Next Release
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-next-i386:templates/win-10-next-i386-20191011 \
            win-10-next-x86_64:templates/win-10-next-x86_64-20191011
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-next-i386-pixa3:templates/tintri-pix-2-vmpooler/win-10-next-i386-20191011 \
            win-10-next-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-10-next-x86_64-20191011

# Windows 7/81
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-7-x86_64:templates/win-7-x86_64-20191011 \
            win-81-x86_64:templates/win-81-x86_64-20191011
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-7-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-7-x86_64-20191011 \
            win-81-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-81-x86_64-20191011

# Windows 2008/2008r2
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2008-x86_64:templates/win-2008-x86_64-20191011 \
            win-2008r2-wmf5-x86_64:templates/win-2008r2-wmf5-x86_64-20191011 \
            win-2008r2-x86_64:templates/win-2008r2-x86_64-20191011 
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2008-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2008-x86_64-20191011 \
            win-2008r2-wmf5-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2008r2-wmf5-x86_64-20191011 \
            win-2008r2-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2008r2-x86_64-20191011

# Windows 2012r2 Primary 
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012r2-x86_64:templates/win-2012r2-x86_64-20191011
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012r2-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-x86_64-20191011

# Windows 2012/2012r2 remainder platforms
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012-x86_64:templates/win-2012-x86_64-20191011 \
            win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20191011 \
            win-2012r2-fips-x86_64:templates/win-2012r2-fips-x86_64-20191011 \
            win-2012r2-ja-x86_64:templates/win-2012r2-ja-x86_64-20191011 \
            win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20191011
#
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012-x86_64-20191011 \
            win-2012r2-core-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-core-x86_64-20191011 \
            win-2012r2-fips-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-fips-x86_64-20191011 \
            win-2012r2-ja-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-ja-x86_64-20191011 \
            win-2012r2-wmf5-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-wmf5-x86_64-20191011

# Windows 2016
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2016-core-x86_64:templates/win-2016-core-x86_64-20191011 \
            win-2016-x86_64:templates/win-2016-x86_64-20191011

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2016-core-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2016-core-x86_64-20191011 \
            win-2016-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2016-x86_64-20191011

# Windows 2019
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2019-core-x86_64:templates/win-2019-core-x86_64-20191011 \
            win-2019-x86_64:templates/win-2019-x86_64-20191011 \
            win-2019-fr-x86_64:templates/win-2019-fr-x86_64-20191011 \
            win-2019-ja-x86_64:templates/win-2019-ja-x86_64-20191011 \
            win-2019-fr-x86_64:templates/win-2019-fr-x86_64-20191011

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2019-core-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2019-core-x86_64-20191011 \
            win-2019-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2019-x86_64-20191011 \
            win-2019-ja-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2019-ja-x86_64-20191011 \
            win-2019-fr-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2019-fr-x86_64-20191011
#Done

# 2016 - IPV6 - clone the templates first - manually....
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2016-x86_64-ipv6:templates/win-2016-x86_64-20191011-ipv6

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2016-x86_64-ipv6-pixa3:templates/tintri-pix-2-vmpooler/win-2016-x86_64-20191011-ipv6


# Example for Mikker: 

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --pools=centos-7.2-tempfs-x86_64:packer/centos-7.2-tmpfs-x86_64-0.0.1_dev_image



# pl-modules update
platform-ci-utils imaging-update-pools-in-pl-modules \
    --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20191011 \
            win-7-wmf5-x86_64:templates/win-7-wmf5-x86_64-20191011 \
            win-10-1511-x86_64:templates/win-10-1511-x86_64-20191011 \
            win-10-1607-x86_64:templates/win-10-1607-x86_64-20191011 \
            win-10-ent-i386:templates/win-10-ent-i386-20191011 \
            win-10-ent-x86_64:templates/win-10-ent-x86_64-20191011 \
            win-2008-x86_64:templates/win-2008-x86_64-20191011 \
            win-2008r2-wmf5-x86_64:templates/win-2008r2-wmf5-x86_64-20191011 \
            win-2008r2-x86_64:templates/win-2008r2-x86_64-20191011 \
            win-2012-x86_64:templates/win-2012-x86_64-20191011 \
            win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20191011 \
            win-2012r2-fr-x86_64:templates/win-2012r2-fr-x86_64-20191011 \
            win-2012r2-ja-x86_64:templates/win-2012r2-ja-x86_64-20191011 \
            win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20191011 \
            win-2012r2-x86_64:templates/win-2012r2-x86_64-20191011 \
            win-2019-core-x86_64:templates/win-2019-core-x86_64-20191011 \
            win-2019-x86_64:templates/win-2019-x86_64-20191011 \
            win-2016-core-x86_64:templates/win-2016-core-x86_64-20191011 \
            win-2016-x86_64:templates/win-2016-x86_64-20191011 \
            win-2016-fr-x86_64:templates/win-2016-fr-x86_64-20191011 \
            win-7-x86_64:templates/win-7-x86_64-20191011 \
            win-81-x86_64:templates/win-81-x86_64-20191011



# June 2019 vmpooler-pool-templates

# Fix Pixa
# Fix win-2019-core, win-2016-fr

# Special Case - these are moving of CI1 into main pix....
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20190613 \
            win-7-wmf5-x86_64:templates/win-7-wmf5-x86_64-20190613 \
            win-10-1511-x86_64:templates/win-10-1511-x86_64-20190613 \
            win-10-1607-x86_64:templates/win-10-1607-x86_64-20190613

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop \
    --pools=win-10-ent-i386:templates/win-10-ent-i386-20190613 \
            win-10-ent-x86_64:templates/win-10-ent-x86_64-20190613

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop \
    --pools=win-7-x86_64:templates/win-7-x86_64-20190613 \
            win-81-x86_64:templates/win-81-x86_64-20190613

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2008-x86_64:templates/win-2008-x86_64-20190613 \
            win-2008r2-wmf5-x86_64:templates/win-2008r2-wmf5-x86_64-20190613 \
            win-2008r2-x86_64:templates/win-2008r2-x86_64-20190613 

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012-x86_64:templates/win-2012-x86_64-20190613 \
            win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20190613 \
            win-2012r2-fr-x86_64:templates/win-2012r2-fr-x86_64-20190613 \
            win-2012r2-ja-x86_64:templates/win-2012r2-ja-x86_64-20190613 \
            win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20190613 \
            win-2012r2-x86_64:templates/win-2012r2-x86_64-20190613

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2016-core-x86_64:templates/win-2016-core-x86_64-20190613 \
            win-2016-fr-x86_64:templates/win-2016-fr-x86_64-20190613 \
            win-2016-x86_64:templates/win-2016-x86_64-20190613

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2019-core-x86_64:templates/win-2019-core-x86_64-20190613 \
            win-2019-x86_64:templates/win-2019-x86_64-20190613

# Pixa machines
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-10-ent-i386-pixa3:templates/tintri-pix-2-vmpooler/win-10-ent-i386-20190613 \
            win-10-ent-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-10-ent-x86_64-20190613 

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-7-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-7-x86_64-20190613 \
            win-81-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-81-x86_64-20190613

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2008-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2008-x86_64-20190613 \
            win-2008r2-wmf5-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2008r2-wmf5-x86_64-20190613 \
            win-2008r2-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2008r2-x86_64-20190613

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2012-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012-x86_64-20190613 \
            win-2012r2-core-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-core-x86_64-20190613 \
            win-2012r2-fr-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-fr-x86_64-20190613 \
            win-2012r2-ja-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-ja-x86_64-20190613 \
            win-2012r2-wmf5-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-wmf5-x86_64-20190613 \
            win-2012r2-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-x86_64-20190613

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2016-core-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2016-core-x86_64-20190613 \
            win-2016-fr-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2016-fr-x86_64-20190613 \
            win-2016-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2016-x86_64-20190613

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci \
    --pools=win-2019-core-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2019-core-x86_64-20190613 \
            win-2019-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2019-x86_64-20190613

# pl-modules update
platform-ci-utils imaging-update-pools-in-pl-modules \
    --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20190613 \
            win-7-wmf5-x86_64:templates/win-7-wmf5-x86_64-20190613 \
            win-10-1511-x86_64:templates/win-10-1511-x86_64-20190613 \
            win-10-1607-x86_64:templates/win-10-1607-x86_64-20190613 \
            win-10-ent-i386:templates/win-10-ent-i386-20190613 \
            win-10-ent-x86_64:templates/win-10-ent-x86_64-20190613 \
            win-2008-x86_64:templates/win-2008-x86_64-20190613 \
            win-2008r2-wmf5-x86_64:templates/win-2008r2-wmf5-x86_64-20190613 \
            win-2008r2-x86_64:templates/win-2008r2-x86_64-20190613 \
            win-2012-x86_64:templates/win-2012-x86_64-20190613 \
            win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20190613 \
            win-2012r2-fr-x86_64:templates/win-2012r2-fr-x86_64-20190613 \
            win-2012r2-ja-x86_64:templates/win-2012r2-ja-x86_64-20190613 \
            win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20190613 \
            win-2012r2-x86_64:templates/win-2012r2-x86_64-20190613 \
            win-2019-core-x86_64:templates/win-2019-core-x86_64-20190613 \
            win-2019-x86_64:templates/win-2019-x86_64-20190613 \
            win-2016-core-x86_64:templates/win-2016-core-x86_64-20190613 \
            win-2016-x86_64:templates/win-2016-x86_64-20190613 \
            win-2016-fr-x86_64:templates/win-2016-fr-x86_64-20190613 \
            win-7-x86_64:templates/win-7-x86_64-20190613 \
            win-81-x86_64:templates/win-81-x86_64-20190613


# April 2019 vmpooler-pool-templates

# Fix Pixa
# Fix win-2019-core, win-2016-fr


platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20190412 win-7-wmf5-x86_64:templates/win-7-wmf5-x86_64-20190412 win-10-1511-x86_64:templates/win-10-1511-x86_64-20190412 win-10-1607-x86_64:templates/win-10-1607-x86_64-20190412

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-10-ent-i386:templates/win-10-ent-i386-20190412 win-10-ent-x86_64:templates/win-10-ent-x86_64-20190412 win-2008-x86_64:templates/win-2008-x86_64-20190412 win-2008r2-wmf5-x86_64:templates/win-2008r2-wmf5-x86_64-20190412 win-2008r2-x86_64:templates/win-2008r2-x86_64-20190412 

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-2012-x86_64:templates/win-2012-x86_64-20190412 win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20190412 win-2012r2-fr-x86_64:templates/win-2012r2-fr-x86_64-20190412 win-2012r2-ja-x86_64:templates/win-2012r2-ja-x86_64-20190412 win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20190412 win-2012r2-x86_64:templates/win-2012r2-x86_64-20190412


platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-2019-core-x86_64:templates/win-2019-core-x86_64-20190412 win-2019-x86_64:templates/win-2019-x86_64-20190412 win-2016-core-x86_64:templates/win-2016-core-x86_64-20190412 win-2016-x86_64:templates/win-2016-x86_64-20190412 win-2016-fr-x86_64:templates/win-2016-fr-x86_64-20190412 win-7-x86_64:templates/win-7-x86_64-20190412 win-81-x86_64:templates/win-81-x86_64-20190412

# Pixa machines
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-10-ent-i386-pixa3:templates/tintri-pix-2-vmpooler/win-10-ent-i386-20190412 win-10-ent-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-10-ent-x86_64-20190412 


platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-2008-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2008-x86_64-20190412 win-2008r2-wmf5-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2008r2-wmf5-x86_64-20190412 win-2008r2-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2008r2-x86_64-20190412

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-2012-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012-x86_64-20190412 win-2012r2-core-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-core-x86_64-20190412 win-2012r2-fr-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-fr-x86_64-20190412 win-2012r2-ja-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-ja-x86_64-20190412 win-2012r2-wmf5-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-wmf5-x86_64-20190412 win-2012r2-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2012r2-x86_64-20190412

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-2019-core-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2019-core-x86_64-20190412 win-2019-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2019-x86_64-20190412 win-2016-core-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2016-core-x86_64-20190412 win-2016-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-2016-x86_64-20190412 win-7-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-7-x86_64-20190412 win-81-x86_64-pixa3:templates/tintri-pix-2-vmpooler/win-81-x86_64-20190412


# pl-modules update

platform-ci-utils imaging-update-pools-in-pl-modules --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20190412 win-7-wmf5-x86_64:templates/win-7-wmf5-x86_64-20190412 win-10-1511-x86_64:templates/win-10-1511-x86_64-20190412 win-10-1607-x86_64:templates/win-10-1607-x86_64-20190412 win-10-ent-i386:templates/win-10-ent-i386-20190412 win-10-ent-x86_64:templates/win-10-ent-x86_64-20190412 win-2008-x86_64:templates/win-2008-x86_64-20190412 win-2008r2-wmf5-x86_64:templates/win-2008r2-wmf5-x86_64-20190412 win-2008r2-x86_64:templates/win-2008r2-x86_64-20190412 win-2012-x86_64:templates/win-2012-x86_64-20190412 win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20190412 win-2012r2-fr-x86_64:templates/win-2012r2-fr-x86_64-20190412 win-2012r2-ja-x86_64:templates/win-2012r2-ja-x86_64-20190412 win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20190412 win-2012r2-x86_64:templates/win-2012r2-x86_64-20190412 win-2019-core-x86_64:templates/win-2019-core-x86_64-20190412 win-2019-x86_64:templates/win-2019-x86_64-20190412 win-2016-core-x86_64:templates/win-2016-core-x86_64-20190412 win-2016-x86_64:templates/win-2016-x86_64-20190412 win-2016-fr-x86_64:templates/win-2016-fr-x86_64-20190412 win-7-x86_64:templates/win-7-x86_64-20190412 win-81-x86_64:templates/win-81-x86_64-20190412



# January 2019 Windows Refresh - Version: 20190111_PROD
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20190111_PROD win-7-wmf5-x86_64:templates/win-7-wmf5-x86_64-20190111_PROD win-10-1511-x86_64:templates/win-10-1511-x86_64-20190111_PROD win-10-1607-x86_64:templates/win-10-1607-x86_64-20190111_PROD

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-10-ent-i386:templates/win-10-ent-i386-20190111_PROD win-10-ent-x86_64:templates/win-10-ent-x86_64-20190111_PROD win-2008-x86_64:templates/win-2008-x86_64-20190111_PROD win-2008r2-wmf5-x86_64:templates/win-2008r2-wmf5-x86_64-20190111_PROD win-2008r2-x86_64:templates/win-2008r2-x86_64-20190111_PROD 

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20190111_PROD win-2012r2-fr-x86_64:templates/win-2012r2-fr-x86_64-20190111_PROD win-2012r2-ja-x86_64:templates/win-2012r2-ja-x86_64-20190111_PROD win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20190111_PROD win-2012r2-x86_64:templates/win-2012r2-x86_64-20190111_PROD
# Defer this one win-2012-x86_64:templates/win-2012-x86_64-20190111_PROD 
platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-2012-x86_64:templates/win-2012-x86_64-20190111_PROD

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-2019-core-x86_64:templates/win-2019-core-x86_64-20190111_PROD win-2019-x86_64:templates/win-2019-x86_64-20190111_PROD win-2016-core-x86_64:templates/win-2016-core-x86_64-20190111_PROD win-2016-x86_64:templates/win-2016-x86_64-20190111_PROD win-7-x86_64:templates/win-7-x86_64-20190111_PROD win-81-x86_64:templates/win-81-x86_64-20190111_PROD

platform-ci-utils imaging-update-pools-in-pl-modules --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20190111_PROD win-7-wmf5-x86_64:templates/win-7-wmf5-x86_64-20190111_PROD win-10-1511-x86_64:templates/win-10-1511-x86_64-20190111_PROD win-10-1607-x86_64:templates/win-10-1607-x86_64-20190111_PROD win-10-ent-i386:templates/win-10-ent-i386-20190111_PROD win-10-ent-x86_64:templates/win-10-ent-x86_64-20190111_PROD win-2008-x86_64:templates/win-2008-x86_64-20190111_PROD win-2008r2-wmf5-x86_64:templates/win-2008r2-wmf5-x86_64-20190111_PROD win-2008r2-x86_64:templates/win-2008r2-x86_64-20190111_PROD  win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20190111_PROD win-2012r2-fr-x86_64:templates/win-2012r2-fr-x86_64-20190111_PROD win-2012r2-ja-x86_64:templates/win-2012r2-ja-x86_64-20190111_PROD win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20190111_PROD win-2012r2-x86_64:templates/win-2012r2-x86_64-20190111_PROD win-2019-core-x86_64-pix:templates/win-2019-core-x86_64-20190111_PROD win-2019-x86_64:templates/win-2019-x86_64-20190111_PROD win-2016-core-x86_64:templates/win-2016-core-x86_64-20190111_PROD win-2016-x86_64:templates/win-2016-x86_64-20190111_PROD win-7-x86_64:templates/win-7-x86_64-20190111_PROD win-81-x86_64:templates/win-81-x86_64-20190111_PROD
# Defer win-2012-x86_64:templates/win-2012-x86_64-20190111_PROD
platform-ci-utils imaging-update-pools-in-pl-modules --pools=win-2012-x86_64:templates/win-2012-x86_64-20190111_PROD


###########################################
# November 2018 Windows Refresh

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20181129_PROD win-7-wmf5-x86_64:templates/win-7-wmf5-x86_64-20181129_PROD win-10-1511-x86_64:templates/win-10-1511-x86_64-20181129_PROD win-10-1607-x86_64:templates/win-10-1607-x86_64-20181129_PROD

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-10-ent-i386:templates/win-10-ent-i386-20181129_PROD win-10-ent-x86_64:templates/win-10-ent-x86_64-20181129_PROD win-2008-x86_64:templates/win-2008-x86_64-20181129_PROD win-2008r2-wmf5-x86_64:templates/win-2008r2-wmf5-x86_64-20181129_PROD win-2008r2-x86_64:templates/win-2008r2-x86_64-20181129_PROD 

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-2012-x86_64:templates/win-2012-x86_64-20181129_PROD win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20181129_PROD win-2012r2-fr-x86_64:templates/win-2012r2-fr-x86_64-20181129_PROD win-2012r2-ja-x86_64:templates/win-2012r2-ja-x86_64-20181129_PROD win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20181129_PROD win-2012r2-x86_64:templates/win-2012r2-x86_64-20181129_PROD

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-2019-core-x86_64-pix:templates/win-2019-core-x86_64-20181129_PROD win-2019-x86_64:templates/win-2019-x86_64-20181129_PROD win-2016-core-x86_64:templates/win-2016-core-x86_64-20181129_PROD win-2016-x86_64:templates/win-2016-x86_64-20181129_PROD win-7-x86_64:templates/win-7-x86_64-20181129_PROD win-81-x86_64:templates/win-81-x86_64-20181129_PROD


platform-ci-utils imaging-update-pools-in-pl-modules --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20181129_PROD win-7-wmf5-x86_64:templates/win-7-wmf5-x86_64-20181129_PROD win-10-1511-x86_64:templates/win-10-1511-x86_64-20181129_PROD win-10-1607-x86_64:templates/win-10-1607-x86_64-20181129_PROD win-10-ent-i386:templates/win-10-ent-i386-20181129_PROD win-10-ent-x86_64:templates/win-10-ent-x86_64-20181129_PROD win-2008-x86_64:templates/win-2008-x86_64-20181129_PROD win-2008r2-wmf5-x86_64:templates/win-2008r2-wmf5-x86_64-20181129_PROD win-2008r2-x86_64:templates/win-2008r2-x86_64-20181129_PROD win-2012-x86_64:templates/win-2012-x86_64-20181129_PROD win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20181129_PROD win-2012r2-fr-x86_64:templates/win-2012r2-fr-x86_64-20181129_PROD win-2012r2-ja-x86_64:templates/win-2012r2-ja-x86_64-20181129_PROD win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20181129_PROD win-2012r2-x86_64:templates/win-2012r2-x86_64-20181129_PROD win-2019-core-x86_64-pix:templates/win-2019-core-x86_64-20181129_PROD win-2019-x86_64:templates/win-2019-x86_64-20181129_PROD win-2016-core-x86_64:templates/win-2016-core-x86_64-20181129_PROD win-2016-x86_64:templates/win-2016-x86_64-20181129_PROD win-7-x86_64:templates/win-7-x86_64-20181129_PROD win-81-x86_64:templates/win-81-x86_64-20181129_PROD


                                                             
# Windows 2019 GA Release

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-2019-core-x86_64:templates/win-2019-core-x86_64-20181004_PROD win-10-ent-i386:templates/win-10-ent-i386-20181004_PROD win-10-ent-x86_64:templates/win-10-ent-x86_64-20181004_PROD win-10-pro-x86_64:templates/win-10-pro-x86_64-20181004_PROD

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-2019-x86_64:templates/win-2019-x86_64-20181004_PROD



platform-ci-utils imaging-update-pools-in-pl-modules --pools=win-2019-core-x86_64:templates/win-2019-core-x86_64-20181004_PROD win-2019-x86_64:templates/win-2019-x86_64-20181004_PROD win-10-ent-i386:templates/win-10-ent-i386-20181004_PROD win-10-ent-x86_64:templates/win-10-ent-x86_64-20181004_PROD win-10-pro-x86_64:templates/win-10-pro-x86_64-20181004_PROD



# Windows 10 ent update (IMAGES-859)

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-10-ent-i386:templates/win-10-ent-i386-20180918_PROD win-10-ent-x86_64:templates/win-10-ent-x86_64-20180918_PROD win-10-pro-x86_64:templates/win-10-pro-x86_64-20180918_PROD

platform-ci-utils imaging-update-pools-in-pl-modules --pools=win-10-ent-i386:templates/win-10-ent-i386-20180918_PROD win-10-ent-x86_64:templates/win-10-ent-x86_64-20180918_PROD win-10-pro-x86_64:templates/win-10-pro-x86_64-20180918_PROD

# Sep 18 Update

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop win-2019-x86_64:templates/win-2019-x86_64-20180912_PROD 


platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20180912_PROD win-7-wmf5-x86_64:templates/win-7-wmf5-x86_64-20180912_PROD win-10-1511-x86_64:templates/win-10-1511-x86_64-20180912_PROD win-10-1607-x86_64:templates/win-10-1607-x86_64-20180912_PROD win-10-1709-x86_64:templates/win-10-1709-x86_64-20180912_PROD win-10-1803-x86_64:templates/win-10-1803-x86_64-20180912_PROD 

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-10-ent-i386:templates/win-10-ent-i386-20180912_PROD win-10-ent-x86_64:templates/win-10-ent-x86_64-20180912_PROD win-2008-x86_64:templates/win-2008-x86_64-20180912_PROD win-2008r2-wmf5-x86_64:templates/win-2008r2-wmf5-x86_64-20180912_PROD win-2008r2-x86_64:templates/win-2008r2-x86_64-20180912_PROD 



platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-2012-x86_64:templates/win-2012-x86_64-20180912_PROD win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20180912_PROD win-2012r2-fr-x86_64:templates/win-2012r2-fr-x86_64-20180912_PROD win-2012r2-ja-x86_64:templates/win-2012r2-ja-x86_64-20180912_PROD win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20180912_PROD win-2012r2-x86_64:templates/win-2012r2-x86_64-20180912_PROD

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --noop --pools=win-2016-core-x86_64:templates/win-2016-core-x86_64-20180912_PROD win-2016-x86_64:templates/win-2016-x86_64-20180912_PROD win-7-x86_64:templates/win-7-x86_64-20180912_PROD win-81-x86_64:templates/win-81-x86_64-20180912_PROD



platform-ci-utils imaging-update-pools-in-pl-modules --pools=win-2019-x86_64:templates/win-2019-x86_64-20180912_PROD win-10-pro-x86_64:templates/win-10-pro-x86_64-20180912_PROD win-7-wmf5-x86_64:templates/win-7-wmf5-x86_64-20180912_PROD win-10-1511-x86_64:templates/win-10-1511-x86_64-20180912_PROD win-10-1607-x86_64:templates/win-10-1607-x86_64-20180912_PROD win-10-1709-x86_64:templates/win-10-1709-x86_64-20180912_PROD win-10-1803-x86_64:templates/win-10-1803-x86_64-20180912_PROD win-10-ent-i386:templates/win-10-ent-i386-20180912_PROD win-10-ent-x86_64:templates/win-10-ent-x86_64-20180912_PROD win-2008-x86_64:templates/win-2008-x86_64-20180912_PROD win-2008r2-wmf5-x86_64:templates/win-2008r2-wmf5-x86_64-20180912_PROD win-2008r2-x86_64:templates/win-2008r2-x86_64-20180912_PROD win-2012-x86_64:templates/win-2012-x86_64-20180912_PROD win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20180912_PROD win-2012r2-fr-x86_64:templates/win-2012r2-fr-x86_64-20180912_PROD win-2012r2-ja-x86_64:templates/win-2012r2-ja-x86_64-20180912_PROD win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20180912_PROD win-2012r2-x86_64:templates/win-2012r2-x86_64-20180912_PROD win-2016-core-x86_64:templates/win-2016-core-x86_64-20180912_PROD win-2016-x86_64:templates/win-2016-x86_64-20180912_PROD win-7-x86_64:templates/win-7-x86_64-20180912_PROD win-81-x86_64:templates/win-81-x86_64-20180912_PROD


# Reverts



platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --pools=win-10-pro-x86_64:templates/win-10-pro-x86_64-20180615_PROD win-7-wmf5-x86_64:templates/win-7-wmf5-x86_64-20180615_PROD win-10-1511-x86_64:templates/win-10-1511-x86_64-20180615_PROD win-10-1607-x86_64:templates/win-10-1607-x86_64-20180615_PROD win-10-1709-x86_64:templates/win-10-1709-x86_64-20180615_PROD win-10-1803-x86_64:templates/win-10-1803-x86_64-20180615_PROD win-2019-x86_64:templates/win-2019-x86_64-20180615_PROD 

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --pools=win-10-ent-i386:templates/win-10-ent-i386-20180615_PROD win-10-ent-x86_64:templates/win-10-ent-x86_64-20180615_PROD win-2008-x86_64:templates/win-2008-x86_64-20180615_PROD win-2008r2-wmf5-x86_64:templates/win-2008r2-wmf5-x86_64-20180615_PROD win-2008r2-x86_64:templates/win-2008r2-x86_64-20180615_PROD 

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --pools=win-2012-x86_64:templates/win-2012-x86_64-20180615_PROD win-2012r2-core-x86_64:templates/win-2012r2-core-x86_64-20180615_PROD win-2012r2-fr-x86_64:templates/win-2012r2-fr-x86_64-20180615_PROD win-2012r2-ja-x86_64:templates/win-2012r2-ja-x86_64-20180615_PROD win-2012r2-wmf5-x86_64:templates/win-2012r2-wmf5-x86_64-20180615_PROD win-2012r2-x86_64:templates/win-2012r2-x86_64-20180615_PROD

platform-ci-utils imaging-update-vmpooler-pool-templates --instance=ci --pools=win-2016-core-x86_64:templates/win-2016-core-x86_64-20180615_PROD win-2016-x86_64:templates/win-2016-x86_64-20180615_PROD win-7-x86_64:templates/win-7-x86_64-20180615_PROD win-81-x86_64:templates/win-81-x86_64-20180615_PROD


