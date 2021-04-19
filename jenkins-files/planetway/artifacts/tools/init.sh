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
persistent_datastore="${persistent_datastore:-/opt/persistent_datastore}"
server_truststore_password="${server_truststore_password:-changeit}"

# configure ejbca
function configure_ejbca() {
  local environment="${environment:-local}"
  local management_ca_name="${environment}_management_ca"
  local management_ca_admin="${management_ca_admin:-superadmin}"
  local management_ca_admin_password="${management_ca_admin_password:-secret}"
  
  ejbca_initialize_ca $management_ca_name 3072 ${persistent_datastore}/${management_ca_name}.crt
  ejbca_create_truststore $management_ca_name ${persistent_datastore}/${management_ca_name}.crt ${persistent_datastore}/truststore.jks $server_truststore_password
  ejbca_create_end_entity $management_ca_name $management_ca_admin $management_ca_admin_password
  ejbca_add_rolemember $management_ca_name 'Super Administrator Role' $management_ca_admin
}

function configure_wildfly() {
  local server_cert="${server_cert:-${persistent_datastore}/server.crt}"
  local server_key="${server_key:-${persistent_datastore}/server.key}"
  local server_key_password="${server_key_password:-secret}"
  local server_name="${server_name:-localhost}"
  local server_keystore_path="${server_keystore_path:-${persistent_datastore}/server.jks}"
  local server_keystore_password="${server_keystore_password:-secret}"
  local server_truststore_path="${server_truststore_path:-${persistent_datastore}/truststore.jks}"

  convert_p12_to_jks $server_cert $server_key $server_key_password $server_name $server_keystore_path $server_keystore_password
  if ! wildfly_https_listener; then
    wildfly_configure_https $server_keystore_path $server_keystore_password $server_truststore_path $server_truststore_password
  fi
}

start_wildfly
configure_ejbca
configure_wildfly
stop_wildfly
