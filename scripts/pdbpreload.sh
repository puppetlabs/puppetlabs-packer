#!/bin/bash

# These should be passed in via custom_provisioning_env
#BRANCH='main'
#PE_VERSION=if blank, gets the latest automatically, otherwise, use what is specified here
#PLATFORM='el-8-x86_64'
if [ -n "${RELEASE}" ]; then
  PE_TARBALL_URL="https://artifactory.delivery.puppetlabs.net/artifactory/generic_enterprise__local/archives/releases/${RELEASE}"
  PE_VERSION="${RELEASE}"
else
  PE_TARBALL_URL="https://artifactory.delivery.puppetlabs.net/artifactory/generic_enterprise__local/${BRANCH}/ci-ready"
fi
EXT='.tar'
BACKUP_DB_URL='http://slv-performance-results.s3-website-us-west-2.amazonaws.com/releases/Kearney/SLV-415/kearney_soak/master'
BACKUP_TAR='db_backup.2019.05.29.tar.gz'
TMP_DIR='/tmp'
PUPPET_BIN='/opt/puppetlabs/bin'
RUN_TUNE=1

set -e

# This isn't really used since we use %{::trusted.certname} below,
# but sometimes we end up getting a spicy-proton name here due to
# some sort of IP reuse thing, and it could cause weirdness.
HOSTNAME=$(hostname -f)
echo "### HOSTNAME = ${HOSTNAME} ###"

df -h
lsblk

# Read LATEST file to grab the latest build from the directory
if [ -z "${PE_VERSION}" ]; then
  VERSION=$(curl ${PE_TARBALL_URL}/LATEST | tr -d '\n')
else
  VERSION=$PE_VERSION
fi

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
  "puppet_enterprise::puppet_master_host": "%{::trusted.certname}"
  "console_admin_password": "puppetlabs",
  "puppet_enterprise::master::recover_configuration::recover_configuration_interval": 0,
  "pe_repo::enable_windows_bulk_pluginsync": true,
  "meep_schema_version": "1.0",
  "puppet_enterprise::profile::puppetdb::node_ttl": "0s",
  "puppet_enterprise::profile::puppetdb::report_ttl": "0s",
  "puppet_enterprise::puppetdb::database_ini::resource_events_ttl": "0s"
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

if [ -n "${RUN_TUNE}" ]; then
  echo '### Running puppet infra tune ###'
  ${PUPPET_BIN}/puppet-infrastructure tune --local --pe_conf

  echo '### Running puppet to apply changes ###'
  ${PUPPET_BIN}/puppet agent -t
fi

set -e

SERVICES=("pe-puppetdb" "pe-console-services" "pe-orchestration-services" "pe-puppetserver" "pe-nginx")

if [ -n "${BACKUP_TAR}" ]; then
  BACKUP_NAME=${BACKUP_TAR/.tar.gz/}
  UPDATETIME_SQL="
  DROP TABLE IF EXISTS max_report;

  SELECT max(producer_timestamp)
  INTO TEMPORARY TABLE max_report
  FROM reports;

  DROP TABLE IF EXISTS max_resource_event;

  SELECT max(timestamp)
  INTO TEMPORARY TABLE max_resource_event
  FROM resource_events;

  DROP TABLE IF EXISTS time_diff;

  SELECT (DATE_PART('day', now() - (select max from max_report)) * 24 +
          DATE_PART('hour', now() - (select max from max_report))) * 60 +
          DATE_PART('minute', now() - (select max from max_report)) as minute_diff
  INTO TEMPORARY TABLE time_diff;

  DROP TABLE IF EXISTS resource_events_time_diff;

  SELECT (DATE_PART('day', now() - (select max from max_resource_event)) * 24 +
          DATE_PART('hour', now() - (select max from max_resource_event))) * 60 +
          DATE_PART('minute', now() - (select max from max_resource_event)) as minute_diff
  INTO TEMPORARY TABLE resource_events_time_diff;

  UPDATE reports
    SET producer_timestamp = producer_timestamp + ((select minute_diff from time_diff) * INTERVAL '1 minute'),
    start_time = start_time + ((select minute_diff from time_diff) * INTERVAL '1 minute'),
    end_time = end_time + ((select minute_diff from time_diff) * INTERVAL '1 minute'),
    receive_time = receive_time + ((select minute_diff from time_diff) * INTERVAL '1 minute');

  UPDATE resource_events
    SET timestamp = timestamp + ((select minute_diff from resource_events_time_diff) * INTERVAL '1 minute');

  UPDATE catalogs
    SET producer_timestamp = producer_timestamp + ((select minute_diff from time_diff) * INTERVAL '1 minute'),
    timestamp = timestamp + ((select minute_diff from time_diff) * INTERVAL '1 minute');

  UPDATE factsets
    SET producer_timestamp = producer_timestamp + ((select minute_diff from time_diff) * INTERVAL '1 minute'),
    timestamp = timestamp + ((select minute_diff from time_diff) * INTERVAL '1 minute');

  DROP TABLE IF EXISTS time_diff;
  DROP TABLE IF EXISTS max_report;
  DROP TABLE IF EXISTS resource_events_time_diff;
  DROP TABLE IF EXISTS max_resource_event;
  "

  PG_SCRIPT="
  log() {
    message=\$1
    ts=\"\$(date +'%Y-%m-%dT%H.%M.%S%z')\"
    echo \"\${ts}: \${message}\"
  }

  log \"Restoring pe-puppetdb\"
  /opt/puppetlabs/server/bin/pg_restore -U pe-postgres --if-exists -cCd template1 ${TMP_DIR}/${BACKUP_NAME}/pe-puppetdb.backup
  log \"Updating pe-puppetdb times\"
  /opt/puppetlabs/server/bin/psql -d pe-puppetdb -a -c \"${UPDATETIME_SQL}\"
  "

  echo '### Downloading backup database ###'
  wget -q -O ${TMP_DIR}/${BACKUP_TAR} ${BACKUP_DB_URL}/${BACKUP_TAR} > /dev/null

  echo '### Extracting backup from tar file ###'
  tar -xf ${TMP_DIR}/${BACKUP_TAR} --directory ${TMP_DIR} --skip-old-files

  echo '### Removing backup tarball ###'
  rm -f ${TMP_DIR}/${BACKUP_TAR}

  for SERVICE in "${SERVICES[@]}"; do
    echo "### Stopping ${SERVICE} ###"
    ${PUPPET_BIN}/puppet resource service ${SERVICE} ensure=stopped >/dev/null
  done

  echo "### Stopping puppet ###"
  ${PUPPET_BIN}/puppet resource service puppet ensure=stopped >/dev/null

  echo '### Restoring PuppetDB database ###'
  echo '### Note: ignore errors about TOC and the public schema ###'
  su - pe-postgres -s /bin/bash -c "${PG_SCRIPT}"

  for SERVICE in "${SERVICES[@]}"; do
    echo "### Restarting ${SERVICE} ###"
    ${PUPPET_BIN}/puppet resource service ${SERVICE} ensure=running >/dev/null
  done

  # Can't rely on puppet resource, as it will exit without the service
  # having actually finished starting up. PuppetDB will likely be
  # doing a very long migraiton, so we need to actually check on it
  # through systemctl.
  echo '### Waiting for pe-puppetdb service to finish starting ###'
  systemctl is-active --quiet pe-puppetdb
  while [[ "$?" != "0" ]]; do
    systemctl is-active --quiet pe-puppetdb
    sleep 1
  done

  set +e
  echo '### Running puppet to register master in pe-puppetdb ###'
  ${PUPPET_BIN}/puppet agent -t

  echo '### Running puppet to reconfigure master based on its presence in PuppetDB ###'
  ${PUPPET_BIN}/puppet agent -t
  set -e

  echo '### Getting access token ###'
  echo puppetlabs | ${PUPPET_BIN}/puppet access login --username admin --lifetime 5y

  echo '### Finding old compiler nodes to purge ###'
  # Because doing a puppet query and interpreting the results in bash is a nightmare,
  # we just take the compilers we know to be in the SLV database.  The
  # query is commented out here for future improvement purposes.
  #${PUPPET_BIN}/puppet query "resources[certname] { type = 'Class' and title = 'Puppet_enterprise::Profile::Master' and certname != '${HOSTNAME}' }"
  OLD_COMPILERS=("ip-10-227-1-160.amz-dev.puppet.net" "ip-10-227-2-122.amz-dev.puppet.net")
  
  for COMPILER in "${OLD_COMPILERS[@]}"; do
    echo "### Purging ${COMPILER} ###"
    ${PUPPET_BIN}/puppet node purge ${COMPILER}
  done

  set +e
  echo '### Running puppet to register old compiler purge ###'
  ${PUPPET_BIN}/puppet agent -t
  set -e
fi
set +e
echo '### Running puppet to clean up any remaining changes ###'
${PUPPET_BIN}/puppet agent -t
set -e

# We should get no changes here
echo '### Running puppet one more time just to be safe ###'
${PUPPET_BIN}/puppet agent -t

# The refresh_master_hostname plan requires user_data.conf to be present
echo '### Running puppet infra recover_configuration to generate user_data.conf ###'
${PUPPET_BIN}/puppet-infrastructure recover_configuration

echo '### Creating refresh_hostname script ###'
echo BOLT_DISABLE_ANALYTICS=true /opt/puppetlabs/installer/bin/bolt --boltdir=/opt/puppetlabs/installer/share/Boltdir plan run enterprise_tasks::testing::refresh_master_hostname > /root/refresh_hostname.sh
chmod +x /root/refresh_hostname.sh

echo '### Setup complete ###'
