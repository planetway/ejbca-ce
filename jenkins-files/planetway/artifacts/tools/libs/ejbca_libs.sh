#!/bin/bash
# ejbca_libs
#
# meant to be source loaded
# e.g.
#   . ./ejbca_libs.sh

function ejbca_command() {
  "$EJBCA_HOME"/bin/ejbca.sh "$@" 2>&1
}

function ejbca_initialize_ca() {
  local ca_name=$1
  local key_size=$2
  local cert_path=$3

  if ! ejbca_command ca listcas | grep $ca_name ; then
    log "INFO" "Initializing CA"
    ejbca_command ca init  --caname $ca_name --dn "CN=${ca_name}" \
                  --tokenType soft --tokenPass null --keytype RSA \
                  --keyspec $key_size -v 3652 --policy null -s SHA384WithRSA \
                  -type x509
  else
    log "INFO" "CA already initialized"
  fi
  
  if [[ ! -f $cert_path ]]; then
    log "INFO" "Dumping CA certificate to filesystem"
    ejbca_command ca getcacert --caname $ca_name \
                  -f $cert_path -der
  fi  
}

function ejbca_create_truststore() {
  local cert_alias=$1
  local cert_path=$2
  local truststore_path=$3
  local truststore_password=$4

  if [[ ! -f $truststore_path ]]; then
    log "INFO" "Creating ejbca truststore"
    keytool -alias $cert_alias -import -trustcacerts -file $cert_path \
            -keystore $truststore_path -storepass $truststore_password -noprompt
  fi
}

function ejbca_create_end_entity() {
  local ca_name=$1
  local end_entity_name=$2
  local end_entity_password=$3

  if ! ejbca_command ra findendentity --username $end_entity_name; then
    log "INFO" "Creating end-entity"
    ejbca_command ra addendentity --username $end_entity_name \
                  --dn "CN=${end_entity_name}" --caname $ca_name \
                  --type 1 --token P12 --password $end_entity_password
  fi
}

function ejbca_add_rolemember() {
  local ca_name=$1
  local role_name=$2
  local end_entity_name=$3
  log "INFO" "Adding member to role"
  ejbca_command roles addrolemember --role "'${role_name}'" \
                --caname $ca_name --with 'WITH_COMMONNAME' \
                --value $end_entity_name
}
