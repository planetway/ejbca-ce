#!/usr/bin/env bash

set -eux

persistent_datastore="${PERSISTENT_DATASTORE:-/opt/persistent_datastore}"
server_truststore_password="${SERVER_TRUSTSTORE_PASSWORD:-changeit}"
server_name="${SERVER_NAME:-localhost}"
server_keystore_path="${SERVER_KEYSTORE_PATH:-${persistent_datastore}/server.jks}"
server_keystore_password="${SERVER_KEYSTORE_PASSWORD:-secret}"

# Fail if the certificate will expire in 24h
keytool -export -keystore $server_keystore_path -alias $server_name -rfc -protected | openssl x509 -checkend 86400 -noout

curl -f http://localhost:8080/ejbca
