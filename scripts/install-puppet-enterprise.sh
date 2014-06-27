#!/bin/bash

# PE can't be installed with PE, so we'll need to use bash for this step

PEVER='3.2.3'
HOSTNAME=$(hostname -f)

cat > /tmp/answers <<EOF
q_all_in_one_install=n
q_database_install=n
q_fail_on_unsuccessful_master_lookup=y
q_install=y
q_puppet_cloud_install=n
q_puppet_enterpriseconsole_install=n
q_puppetagent_certname=${HOSTNAME}
q_puppetagent_install=y
q_puppetagent_server=puppet
q_puppetca_install=n
q_puppetdb_install=n
q_puppetmaster_install=n
q_run_updtvpkg=n
q_vendor_packages_install=y
q_fail_on_unsuccessful_master_lookup=n
EOF

case ${OPERATINGSYSTEM} in
  debian)
    RELEASEVERMAJ=$(lsb_release -r -s | sed -e 's/\.[0-9]*$//g')

    case ${RELEASEVERMAJ} in
      6.0)
        RELEASEVERMAJ='6'
      ;;
    esac

    case ${ARCHITECTURE} in
      x86_64)
        ARCHITECTURE='amd64'
      ;;
    esac

    PE_TAR="puppet-enterprise-${PEVER}-${OPERATINGSYSTEM}-${RELEASEVERMAJ}-${ARCHITECTURE}"
    ;;

  oracle)
    RELEASEVERMAJ=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release) | sed -e 's/Server//g')
    PE_TAR="puppet-enterprise-${PEVER}-el-${RELEASEVERMAJ}-${ARCHITECTURE}"
    ;;

  redhat)
    RELEASEVERMAJ=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release))
    PE_TAR="puppet-enterprise-${PEVER}-el-${RELEASEVERMAJ}-${ARCHITECTURE}"
    ;;

  scientific)
    RELEASEVERMAJ=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release) | sed -e 's/\.[0-9]*$//g')
    PE_TAR="puppet-enterprise-${PEVER}-el-${RELEASEVERMAJ}-${ARCHITECTURE}"
    ;;

  ubuntu)
    RELEASEVERMAJ=$(lsb_release -r -s)

    case ${ARCHITECTURE} in
      x86_64)
        ARCHITECTURE='amd64'
      ;;
    esac

    PE_TAR="puppet-enterprise-${PEVER}-${OPERATINGSYSTEM}-${RELEASEVERMAJ}-${ARCHITECTURE}"
    ;;
esac


PE_URL="http://pe-releases.puppetlabs.lan/${PEVER}/${PE_TAR}.tar.gz"

tarball_path=$(mktemp)
wget --output-document="${tarball_path}" "${PE_URL}"

cd /tmp ; tar -zxvf ${tarball_path} ; rm ${tarball_path} ; cd ${PE_TAR}
./puppet-enterprise-installer -a /tmp/answers

cd /tmp ; rm -rf ${PE_TAR} ; rm answers

#--

# Show Puppet version
printf 'Puppet ' ; /opt/puppet/bin/puppet --version

# Installed required modules
for i in "$@"
do
  /opt/puppet/bin/puppet module install $i --modulepath=/tmp/packer-puppet-masterless/manifests/modules >/dev/null 2>&1
done

printf 'Modules installed in ' ; /opt/puppet/bin/puppet module list --modulepath=/tmp/packer-puppet-masterless/manifests/modules
