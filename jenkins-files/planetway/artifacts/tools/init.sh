#!/bin/bash

# set relative path
script_path="$( cd "$(dirname "$0")" || exit ; pwd -P )"

# include libaries
libraries="common_libs.sh ejbca_libs.sh wildfly_libs.sh"
for l in $libraries; do
  # shellcheck source=libs/*.sh
  . "$script_path/libs/$l"
    test $? -ne 0 &&\
      echo "failed loading $l from '$l'" &&\
      exit 1
done

# global variables
persistent_datastore="${PERSISTENT_DATASTORE:-/opt/persistent_datastore}"
server_truststore_password="${SERVER_TRUSTSTORE_PASSWORD:-changeit}"

# configure ejbca
function configure_ejbca() {
  local environment="${ENVIRONMENT:-local}"
  local management_ca_admin="${MANAGEMENT_CA_ADMIN:-superadmin}"
  local management_ca_admin_password="${MANAGEMENT_CA_ADMIN_PASSWORD:-secret}"
  local management_ca_name="${environment}_management_ca"
  
  ejbca_initialize_ca $management_ca_name 3072 ${persistent_datastore}/${management_ca_name}.crt
  ejbca_create_truststore $management_ca_name ${persistent_datastore}/${management_ca_name}.crt ${persistent_datastore}/truststore.jks $server_truststore_password
  ejbca_create_end_entity $management_ca_name $management_ca_admin $management_ca_admin_password
  ejbca_add_rolemember $management_ca_name 'Super Administrator Role' $management_ca_admin
}

function configure_wildfly() {
  local server_cert="${SERVER_CERT:-${persistent_datastore}/server.crt}"
  local server_key="${SERVER_KEY:-${persistent_datastore}/server.key}"
  local server_key_password="${SERVER_KEY_PASSWORD:-secret}"
  local server_name="${SERVER_NAME:-localhost}"
  local server_keystore_path="${SERVER_KEYSTORE_PATH:-${persistent_datastore}/server.jks}"
  local server_keystore_password="${SERVER_KEYSTORE_PASSWORD:-secret}"
  local server_truststore_path="${SERVER_TRUSTSTORE_PATH:-${persistent_datastore}/truststore.jks}"

  convert_p12_to_jks $server_cert $server_key $server_key_password $server_name $server_keystore_path $server_keystore_password
  if ! wildfly_https_listener; then
    wildfly_configure_https $server_keystore_path $server_keystore_password $server_key_password $server_truststore_path $server_truststore_password
  fi
}

start_wildfly
configure_ejbca
configure_wildfly
stop_wildfly
