#!/bin/bash

SCRIPT_PATH="$( cd "$(dirname "$0")" || exit ; pwd -P )"

# shellcheck source=scripts/helper_libs.sh
. "${SCRIPT_PATH}/libs/helper_libs.sh"
  test $? -ne 0 &&\
    echo "failed loading helper libs from 'libs/helper_libs.sh'" &&\
    exit 1

set -e

environment="${environment:-local}"
ca_name="${environment}_management_ca"
admin_user="${admin_user:-superadmin}"
admin_user_password="${admin_user_password:-secret}"

if ! ${EJBCA_HOME}/bin/ejbca.sh ca listcas | grep $ca_name ; then
  log "INFO" "Initializing management CA"
  ${EJBCA_HOME}/bin/ejbca.sh ca init  --caname $ca_name --dn "CN=${ca_name}" --tokenType soft \
                      --tokenPass null --keytype RSA --keyspec 3072 -v 3652 \
                      --policy null -s SHA384WithRSA -type x509
fi

if ! ${EJBCA_HOME}/bin/ejbca.sh ra findendentity --username $admin_user; then
  log "INFO" "Creating admin user"
  ${EJBCA_HOME}/bin/ejbca.sh ra addendentity --username $admin_user --dn "CN=${admin_user}" --caname $ca_name --type 1 --token P12 --password $admin_user_password
  ${EJBCA_HOME}/bin/ejbca.sh roles removeadmin --role 'Super Administrator Role' --caname "" --with PublicAccessAuthenticationToken:TRANSPORT_CONFIDENTIAL --value ""
  ${EJBCA_HOME}/bin/ejbca.sh roles addrolemember --role 'Super Administrator Role' --caname $ca_name --with 'WITH_COMMONNAME' --value $admin_user
fi
