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
puppet resource service puppet ensure=stopped enable=false

echo '### Creating refresh_hostname script ###'

set -e
cat <<'EOF' > /opt/puppetlabs/installer/share/Boltdir/site-modules/enterprise_tasks/plans/testing/refresh_master_hostname.pp
# Note: This plan requires user_data.conf to be present. We can't run
# it from inside this plan since the plan is meant to be run AFTER
# the hostname has already changed and therefore
# puppet infra recover_configuration will not work correctly.
plan enterprise_tasks::testing::refresh_master_hostname(
  Optional[TargetSpec] $master              = 'localhost',
  Optional[String]     $old_master_certname = undef,
) {
  $puppet_bin = constants()['puppet_bin']
  $master_target = get_targets($master)[0]
  run_plan('facts', 'targets' => $master_target)
  $master_fqdn = $master_target.facts()['fqdn']

  # Get old certname. This is overrideable in case the plan has issues part way
  # and puppet.conf has already been modified.
  $current_puppet_certname = run_command('/opt/puppetlabs/bin/puppet config print certname --section main', $master).first.value['stdout'][0,-2]
  $prev_master_certname = empty($old_master_certname) ? {
    true  => $current_puppet_certname,
    false => $old_master_certname,
  }

  if $master_fqdn == $prev_master_certname {
    enterprise_tasks::message('refresh_master_hostname', "Current hostname ${master_fqdn} has not changed. Exiting.")
    return undef
  }
  enterprise_tasks::message('refresh_master_hostname', "Changing master hostname from ${prev_master_certname} to ${master_fqdn}...")

  $status_hash = run_plan(enterprise_tasks::get_service_status, target => $master,
    service    => 'puppet')

  ### Disabled until we are ready to make this user-facing ###
  # Replicas and compilers both have the master role, external postgres has the database role,
  # so this should cover all of the infra nodes. 
  #$infra_nodes = enterprise_tasks::get_nodes_with_role('master') + enterprise_tasks::get_nodes_with_role('database')
  #$infra_non_primary = $infra_nodes.flatten.unique.filter |$node| { $node != $master_fqdn and $node != $current_puppet_certname }
  $result_or_error = catch_errors() || {
    # Change this to [$master] + $infra_non_primary when we make this user-facing
    enterprise_tasks::message('refresh_master_hostname', 'Stopping PE services...')
    run_task(enterprise_tasks::disable_all_puppet_services, $master)

    enterprise_tasks::message('refresh_master_hostname', 'Modifying configuration files to use new hostname...')
    run_command("sed -i 's/${prev_master_certname}/${master_fqdn}/g' /etc/puppetlabs/puppet/puppet.conf", $master)
    run_command("sed -i 's/${prev_master_certname}/${master_fqdn}/g' /etc/puppetlabs/enterprise/conf.d/pe.conf", $master)
    # Because we have to set up the pdbpreload VM using the trusted certname fact for puppet_master host,
    # and having puppet_master_host set to the trusted fact causes problems when pe.conf gets copied elsewhere,
    # we replace instances of the trusted fact as well. May not want this if we make the plan user-facing.
    run_command("sed -i 's/%{::trusted.certname}/${master_fqdn}/g' /etc/puppetlabs/enterprise/conf.d/pe.conf", $master)
    run_command("sed -i 's/${prev_master_certname}/${master_fqdn}/g' /etc/puppetlabs/enterprise/conf.d/user_data.conf", $master)

    # These will get regenerated. We're clearing them out here because while puppet
    # will add configuration for the new certname, it will not remove the old certname
    run_command('echo > /etc/puppetlabs/nginx/conf.d/proxy.conf', $master)
    run_command('echo > /etc/puppetlabs/nginx/conf.d/http_redirect.conf', $master)
    run_command('echo > /etc/puppetlabs/puppetdb/certificate-whitelist', $master)
    run_command('echo > /etc/puppetlabs/console-services/rbac-certificate-whitelist', $master)

    enterprise_tasks::message('refresh_master_hostname', 'Clearing cached catalogs...')
    run_command('rm -f /opt/puppetlabs/puppet/cache/client_data/catalog/*', $master)

    ### Disabled until we are ready to make this user-facing ###
    #enterprise_tasks::message('refresh_master_hostname', 'Modifying puppet.conf on infrastructure nodes...')
    # We have to modify puppet.conf here first because master_cert_regen will run puppet 
    # and regen the cert on an external postgres node.
    #$infra_non_primary.each |$node| {
    #  run_command("sed -i 's/${prev_master_certname}/${master_fqdn}/g' /etc/puppetlabs/puppet/puppet.conf", $node)
    #}

    # We have to skip past verification since the verify_node task won't be able to talk to PDB
    # as it will still be pointing at the old certname
    run_plan(enterprise_tasks::master_cert_regen, master => $master, force => true)

    # For some totally bizarre reason, on at least Ubuntu (not sure about other platforms),
    # about half the time the RBAC service in pe-console-services gets into a weird state
    # and just returns 500s when you try to do a node purge. Restarting the service
    # fixes it, instead of wasting more time trying to root cause this weird bug,
    # I'm just restarting it here.
    run_task(service, $master,
            action        => 'restart',
            name          => 'pe-console-services')

    enterprise_tasks::message('refresh_master_hostname', 'Purging old master certname and deleting its certificate...')
    run_command("${puppet_bin} node purge ${prev_master_certname}", $master)
    run_task(enterprise_tasks::delete_cert, $master, certname => $prev_master_certname)

    enterprise_tasks::message('refresh_master_hostname', 'Unpinning old certname from PE node groups...')
    run_command("${puppet_bin} resource pe_node_group 'PE Certificate Authority' unpinned='${prev_master_certname}'", $master)
    run_command("${puppet_bin} resource pe_node_group 'PE Console' unpinned='${prev_master_certname}'", $master)
    run_command("${puppet_bin} resource pe_node_group 'PE Database' unpinned='${prev_master_certname}'", $master)
    run_command("${puppet_bin} resource pe_node_group 'PE Master' unpinned='${prev_master_certname}'", $master)
    run_command("${puppet_bin} resource pe_node_group 'PE Orchestrator' unpinned='${prev_master_certname}'", $master)
    run_command("${puppet_bin} resource pe_node_group 'PE PuppetDB' unpinned='${prev_master_certname}'", $master)
    $ha_master_group = run_command("${puppet_bin} resource pe_node_group 'PE HA Master'", $master).first.value['stdout']
    if $ha_master_group =~ /present/ {
      run_command("${puppet_bin} resource pe_node_group 'PE HA Master' unpinned='${prev_master_certname}'")
    }

    enterprise_tasks::message('refresh_master_hostname', 'Running puppet to populate services.conf with new certname...')
    run_task(enterprise_tasks::run_puppet, $master)

    ### Disabled until we are ready to make this user-facing ###
    #enterprise_tasks::message('refresh_master_hostname', 'Running puppet on infrastructure nodes...')
    #$infra_non_primary.each |$node| {
    #  run_task(enterprise_tasks::run_puppet, $node, max_timeout => 256)
    #}
  }
  enterprise_tasks::message('refresh_master_hostname', 'Applying original agent state...')
  run_command("${puppet_bin} resource service puppet ensure=${status_hash[status]} enable=${status_hash[enabled]}", $master)
  if $result_or_error =~ Error {
    fail_plan($result_or_error)
  }
}
EOF
date > /tmp/packer_build
ls /opt/puppetlabs/installer/share/Boltdir/site-modules/enterprise_tasks/plans
echo BOLT_DISABLE_ANALYTICS=true /opt/puppetlabs/installer/bin/bolt --boltdir=/opt/puppetlabs/installer/share/Boltdir plan run enterprise_tasks::testing::refresh_master_hostname > /root/refresh_hostname.sh
chmod +x /root/refresh_hostname.sh

echo '### Setup complete ###'
