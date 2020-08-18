#!/bin/bash

# These should be passed in via custom_provisioning_env
#VERSION='2018.1.15'
#PLATFORM='el-7-x86_64'

PE_TARBALL_URL="https://artifactory.delivery.puppetlabs.net/artifactory/generic_enterprise__local/archives/releases/${VERSION}"
EXT='.tar'
TMP_DIR='/tmp'
PUPPET_BIN='/opt/puppetlabs/bin'

set -e
set -x


NAME="puppet-enterprise-${VERSION}-${PLATFORM}"
TARBALL="${NAME}${EXT}"
FULL_TARBALL_URL="${PE_TARBALL_URL}/${TARBALL}"

echo "### Downloading PE tarball from ${FULL_TARBALL_URL} and saving to ${TMP_DIR} ###"
wget -q -O ${TMP_DIR}/${TARBALL} ${FULL_TARBALL_URL} 
echo '### Exploding tarball ###'
tar -xf ${TMP_DIR}/${TARBALL} --directory ${TMP_DIR}
echo '### Removing tarball ###'
rm -f ${TMP_DIR}/${TARBALL}

echo '### Setting up pe.conf ###'
cat << EOF > ${TMP_DIR}/pe.conf
{
  "puppet_enterprise::puppet_master_host": "%{::trusted.certname}",
  "console_admin_password": "puppetlabs"
}
EOF

echo '### Running installer ###'
${TMP_DIR}/${NAME}/puppet-enterprise-installer -y -c ${TMP_DIR}/pe.conf

# Puppet runs with changes exit 2
set +e

echo '### First puppet run post-install ###'
${PUPPET_BIN}/puppet agent -t

echo '### Second puppet run post-install ###'
${PUPPET_BIN}/puppet agent -t

# The refresh_master_hostname plan requires user_data.conf to be present
echo '### Running puppet infra recover_configuration to generate user_data.conf ###'
${PUPPET_BIN}/puppet-infrastructure recover_configuration

# Stop all services and disable puppet here instead of at the beginning of the refresh 
# hostname script. This saves time in CI
puppet resource service puppet ensure=stopped enable=false
puppet agent --disable
puppet resource service pe-nginx ensure=stopped
puppet resource service pe-console-services ensure=stopped
puppet resource service pe-puppetserver ensure=stopped
puppet resource service pe-bolt-server ensure=stopped
puppet resource service pe-ace-server ensure=stopped
puppet resource service pe-orchestration-services ensure=stopped
puppet resource service pe-puppetdb ensure=stopped
puppet resource service pe-postgresql ensure=stopped


echo '### Creating refresh_hostname script ###'

set -e
cat <<'EOF' > /root/refresh_hostname.sh
# Note: This script is a simplification of our refresh_master_hostname plan found
# in enterprise tasks, and is created to be used in preloaded images to speed up
# refreshing as these nodes do not need the extra user-facing features and verification
# steps that the plan does. If you wish to refresh your hostname on anything 
# other than preloaded images we suggest you use our plan instead.

master='localhost'
master_fqdn=$(facter fqdn)
prev_master_certname=$(/opt/puppetlabs/bin/puppet config print certname --section main)

if [[ "$master_fqdn" == "$prev_master_certname" ]]
then
    echo "Current hostname ${master_fqdn} has not changed. Exiting."
    exit 1
fi

echo "Changing master hostname from $prev_master_certname to ${master_fqdn}..."

echo 'Modifying configuration files to use new hostname...'
sed -i "s/$prev_master_certname/${master_fqdn}/g" /etc/puppetlabs/puppet/puppet.conf
sed -i "s/$prev_master_certname/${master_fqdn}/g" /etc/puppetlabs/enterprise/conf.d/pe.conf
sed -i "s/%{::trusted.certname}/${master_fqdn}/g" /etc/puppetlabs/enterprise/conf.d/pe.conf
sed -i "s/$prev_master_certname/${master_fqdn}/g" /etc/puppetlabs/enterprise/conf.d/user_data.conf

# Remove old certname
echo > /etc/puppetlabs/nginx/conf.d/proxy.conf
echo > /etc/puppetlabs/nginx/conf.d/http_redirect.conf
echo > /etc/puppetlabs/puppetdb/certificate-whitelist
echo > /etc/puppetlabs/console-services/rbac-certificate-whitelist

echo 'Clearing cached catalogs...'
rm -f /opt/puppetlabs/puppet/cache/client_data/catalog/*
# Master Cert Regen 

# Remove Cache
certname=$(/opt/puppetlabs/bin/puppet config print certname)
rm -rf  "/opt/puppetlabs/puppet/cache/client_data/catalog/${certname}.json"

# Delete Cert
cert_locations=( '/etc/puppetlabs/puppet/ssl' '/etc/puppetlabs/puppetdb/ssl' '/etc/puppetlabs/ace-server/ssl' '/etc/puppetlabs/bolt-server/ssl' '/etc/puppetlabs/orchestration-services/ssl' '/opt/puppetlabs/server/data/console-services/certs')
for location in "${cert_locations[@]}"
do
    test -e "${location}"
    exit_status=$?
    if [ $exit_status -eq 1 ]; then
        echo "Nothing found in ${location}"
        continue
    fi
    find "${location}" -name "${certname}".* -delete
done

puppet infrastructure configure --no-recover
puppet agent --enable
puppet agent -t


# For some totally bizarre reason, on at least Ubuntu (not sure about other platforms),
# about half the time the RBAC service in pe-console-services gets into a weird state
# and just returns 500s when you try to do a node purge. Restarting the service
# fixes it, instead of wasting more time trying to root cause this weird bug,
# I'm just restarting it here.
service pe-console-services restart 


echo 'Purging old master certname and deleting its certificate...'
/opt/puppetlabs/bin/puppet node purge "$prev_master_certname"

# Delete Old Certs
old_cert_locations=( '/etc/puppetlabs/puppet/ssl' '/etc/puppetlabs/puppetdb/ssl' '/etc/puppetlabs/ace-server/ssl' '/etc/puppetlabs/bolt-server/ssl' '/etc/puppetlabs/orchestration-services/ssl' '/opt/puppetlabs/server/data/console-services/certs')
for location in "${old_cert_locations[@]}"
do
    test -e "${location}"
    exit_status=$?
    if [ $exit_status -eq 1 ]; then
        echo "Nothing found in ${location}"
        continue
    fi
    find "${location}" -name "${prev_master_certname}".* -delete
done
echo 'Unpinning old certname from PE node groups...'
/opt/puppetlabs/bin/puppet resource pe_node_group 'PE Certificate Authority' unpinned="$prev_master_certname"
/opt/puppetlabs/bin/puppet resource pe_node_group 'PE Console' unpinned="$prev_master_certname"
/opt/puppetlabs/bin/puppet resource pe_node_group 'PE Database' unpinned="$prev_master_certname"
/opt/puppetlabs/bin/puppet resource pe_node_group 'PE Master' unpinned="$prev_master_certname"
/opt/puppetlabs/bin/puppet resource pe_node_group 'PE Orchestrator' unpinned="$prev_master_certname"
/opt/puppetlabs/bin/puppet resource pe_node_group 'PE PuppetDB' unpinned="$prev_master_certname"

echo 'Running puppet to populate services.conf with new certname...'
puppet agent -t
echo 'Complete' 
EOF

cat << EOF > /etc/motd
###########################################################################
This is an image preloaded with PE 2018.1.15. If you are using pooler, run
the refresh_hostname script via ./refresh_hostname.sh in the root directory
to update to the new spicy-proton style hostname.
###########################################################################
EOF
date > /tmp/packer_build
chmod +x /root/refresh_hostname.sh

echo '### Setup complete ###'
