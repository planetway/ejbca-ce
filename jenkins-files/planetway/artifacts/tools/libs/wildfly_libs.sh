#!/bin/bash
# wildfly_libs
#
# meant to be source loaded
# e.g.
#   . ./wildfly_libs.sh

function wildfly_command() {
  /opt/wildfly/bin/jboss-cli.sh --connect "$1"
}

function wildfly_not_ready() {
  local status

  status=$(wildfly_command ":read-attribute(name=server-state)" | grep "result")
  [[ "$status" =~ "running" ]] && return 0 || return 1
}

function wildfly_https_listener() {
  /opt/wildfly/bin/jboss-cli.sh -c "/subsystem=undertow/server=default-server/https-listener=httpspriv:read-resource" | grep -q "success"
}

function wait_for_wildfly() {
  retry_while wildfly_not_ready
}

function start_wildfly() {
  log "INFO" "Starting wildfly"
  $WILDFLY_HOME/bin/standalone.sh -b 0.0.0.0 &
}

function stop_wildfly() {
  log "INFO" "Shutting down wildfly"
  wildfly_command ":shutdown"
}

function wildfly_configure_https() {
  local keystore_path=$1
  local keystore_password=$2
  local key_password=$3
  local truststore_path=$4
  local truststore_password=$5

  log "INFO" "Add New Interfaces and Sockets"
  wildfly_command '/interface=http:add(inet-address="0.0.0.0")'
  wildfly_command '/interface=httpspub:add(inet-address="0.0.0.0")'
  wildfly_command '/interface=httpspriv:add(inet-address="0.0.0.0")'
  wildfly_command '/socket-binding-group=standard-sockets/socket-binding=http:add(port="8080",interface="http")'
  wildfly_command '/socket-binding-group=standard-sockets/socket-binding=httpspub:add(port="8442",interface="httpspub")'
  wildfly_command '/socket-binding-group=standard-sockets/socket-binding=httpspriv:add(port="8443",interface="httpspriv")'

  log "INFO" "Configure TLS"
  wildfly_command "/subsystem=elytron/key-store=httpsKS:add(path=\"$keystore_path\",credential-reference={clear-text=\"$keystore_password\"},type=JKS)"
  wildfly_command "/subsystem=elytron/key-store=httpsTS:add(path=\"$truststore_path\",credential-reference={clear-text=\"$truststore_password\"},type=JKS)"
  wildfly_command "/subsystem=elytron/key-manager=httpsKM:add(key-store=httpsKS,algorithm=\"SunX509\",credential-reference={clear-text=\"$key_password\"})"
  wildfly_command '/subsystem=elytron/trust-manager=httpsTM:add(key-store=httpsTS)'
  wildfly_command '/subsystem=elytron/server-ssl-context=httpspub:add(key-manager=httpsKM,protocols=["TLSv1.2"])'
  wildfly_command '/subsystem=elytron/server-ssl-context=httpspriv:add(key-manager=httpsKM,protocols=["TLSv1.2"],trust-manager=httpsTM,need-client-auth=false,authentication-optional=true,want-client-auth=true)'

  log "INFO" "Add HTTP(S) Listeners"
  wildfly_command '/subsystem=undertow/server=default-server/http-listener=http:add(socket-binding="http", redirect-socket="httpspriv")'
  wildfly_command '/subsystem=undertow/server=default-server/https-listener=httpspub:add(socket-binding="httpspub", ssl-context="httpspub", max-parameters=2048)'
  wildfly_command '/subsystem=undertow/server=default-server/https-listener=httpspriv:add(socket-binding="httpspriv", ssl-context="httpspriv", max-parameters=2048)'
}
