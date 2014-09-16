#!/usr/bin/env bash

cat > /tmp/answers <<EOF
q_all_in_one_install=n
q_continue_or_reenter_master_hostname=c
q_database_install=n
q_fail_on_unsuccessful_master_lookup=n
q_install=y
q_puppet_cloud_install=n
q_puppet_enterpriseconsole_install=n
q_puppetagent_certname=scratch.debian
q_puppetagent_install=y
q_puppetagent_server=puppet
q_puppetca_install=n
q_puppetdb_install=n
q_puppetmaster_install=n
q_run_updtvpkg=n
q_vendor_packages_install=y
EOF

## extract and install PE
tar -xzvf pe.tar.gz
cd `ls -d puppet*`
./puppet-enterprise-installer -a /tmp/answers

# Install required modules
for i in "$@"
do
  puppet module install $i --modulepath=/tmp/manifests/modules >/dev/null 2>&1
done

puppet apply /tmp/manifests/ec2.pp --modulepath=/tmp/manifests/modules

## uninstall puppet
sudo ./puppet-enterprise-uninstaller -y
cd ..
rm -rf `ls -d puppet*`
rm pe.tar.gz
sed -i "s/disable_root: true/disable_root: 0/" /etc/cloud/cloud.cfg
if ! [ -d /usr/local/bin ];
then
  mkdir /usr/local/bin
fi

## clean up
rm -rf /etc/puppetlabs
rm -rf /opt/puppet
rm -rf /var/cache/yum/puppetdeps
rm -rf /var/opt/lib/pe-puppet
rm -rf /tmp/*
cat /dev/null > /var/log/wtmp
rm /root/.ssh/authorized_keys
