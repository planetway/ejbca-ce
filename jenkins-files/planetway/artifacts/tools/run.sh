#!/bin/bash

# verbose logging
[[ $TRACE ]] && set -x

SCRIPT_PATH="$( cd "$(dirname "$0")" || exit ; pwd -P )"

# shellcheck source=scripts/common_libs.sh
. "${SCRIPT_PATH}/libs/common_libs.sh"
  test $? -ne 0 &&\
    echo "failed loading helper libs from 'libs/common_libs.sh'" &&\
    exit 1

check_variable $DATABASE_JDBC_URL
check_variable $DATABASE_USER
check_variable $DATABASE_PASSWORD

# Database variables for clientToolBox
DATABASE_USER_PRIVILEGED="${DATABASE_USER_PRIVILEGED:-$DATABASE_USER}"
DATABASE_PASSWORD_PRIVILEGED="${DATABASE_PASSWORD_PRIVILEGED:-$DATABASE_PASSWORD}"

# Link JDBC driver for clientToolBox
if [ -f ${WILDFLY_HOME}/standalone/deployments/postgresql.jar ] ; then
  mkdir -p ${EJBCA_HOME}/dist/clientToolBox/ext
  ln -s ${WILDFLY_HOME}/standalone/deployments/postgresql.jar ${EJBCA_HOME}/dist/clientToolBox/ext/postgresql.jar
fi

# Wait for external database to become available
while [ true ] ; do
  ${EJBCA_HOME}/dist/clientToolBox/ejbcaClientToolBox.sh jdbc --url "${DATABASE_JDBC_URL}" --username "${DATABASE_USER}" --password "${DATABASE_PASSWORD}" --execute "SELECT 1;"
  if [ $? == 0 ] ; then
    break
  else
    log "INFO" "Waiting for external database '${DATABASE_JDBC_URL}' to become available."
    sleep 3
  fi
done

# Check if we have database tables and indexes
${EJBCA_HOME}/dist/clientToolBox/ejbcaClientToolBox.sh jdbc --url "${DATABASE_JDBC_URL}" --username "${DATABASE_USER}" --password "${DATABASE_PASSWORD}" --execute "SELECT rowVersion FROM GlobalConfigurationData WHERE configurationId='UPGRADE';"
errorCode=$?
if [ $errorCode != 0 ] ; then
  if [ $errorCode != 4 ] ; then
    # Query failed with error and since database is reachable, we assume this is caused by there being no database tables yet
    log "INFO" "Creating database tables..."
    ${EJBCA_HOME}/dist/clientToolBox/ejbcaClientToolBox.sh jdbc --url "${DATABASE_JDBC_URL}" --username "${DATABASE_USER_PRIVILEGED}" --password "${DATABASE_PASSWORD_PRIVILEGED}" \
      --file "${EJBCA_HOME}/doc/sql-scripts/create-tables-ejbca-postgres.sql"
  fi
  # Query failed either with missing tables (that has now just been corrected) or a SELECT miss indicating that the application has never started... either way we need to create indexes
  log "INFO" "Applying recommended database indexes..."
  ${EJBCA_HOME}/dist/clientToolBox/ejbcaClientToolBox.sh jdbc --url "${DATABASE_JDBC_URL}" --username "${DATABASE_USER_PRIVILEGED}" --password "${DATABASE_PASSWORD_PRIVILEGED}" \
    --file "${EJBCA_HOME}/doc/sql-scripts/create-index-ejbca.sql"
fi

log "INFO" "Running init.sh"
${SCRIPT_PATH}/init.sh

log "INFO" "Starting wildfly"
$WILDFLY_HOME/bin/standalone.sh -b 0.0.0.0
