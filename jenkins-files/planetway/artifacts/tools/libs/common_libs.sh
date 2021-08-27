#!/usr/bin/env bash
# common_libs
#
# meant to be source loaded
# e.g.
#   . ./common_libs.sh

function check_variable() {
  if [ -z ${1+x} ]; then
    echo "Database variable(s) are unset!"
    echo "Exiting.."
    exit 1
  fi
}

function log() {
  # 2019-01-15 12:03:43,047
  dateString="$(date +%Y-%m-%d' '%R:%S,%N%z | sed 's/\(.*\)......\(.....\)/\1\2/')"
  logLevel=$(printf '%-5s' "${1:-INFO}")
  className="$0"
  processId="$$"
  #threadId="$(ps H -o 'tid' $processId | tail -n 1| tr -d ' ')"
  if [ -z "$2" ] ; then
    while read line ; do
      echo "{\"timestamp\":\"$dateString\",\"level\":\"$logLevel\",\"loggerClassName\":\"$className\",\"processId\":\"$processId\",\"message\":\"${line}\"}"
    done
  else
    echo "{\"timestamp\":\"$dateString\",\"level\":\"$logLevel\",\"loggerClassName\":\"$className\",\"processId\":\"$processId\",\"message\":\"${2}\"}"
  fi
}

function convert_p12_to_jks () {
  local cert=$1
  local key=$2
  local key_password=$3
  local alias=$4
  local jks_path=$5
  local jks_password=$6
  
  if [[ ! -f $jks_path ]]; then
    openssl pkcs12  -export -in $cert -inkey $key -name $alias \
                    -out /tmp/keystore.p12 \
                    -passin pass:${key_password} -passout pass:${key_password}

    keytool -importkeystore -noprompt \
            -srckeystore /tmp/keystore.p12 \
            -srcstorepass $key_password \
            -destkeystore $jks_path \
            -deststorepass $jks_password \
            -deststoretype jks
    rm /tmp/keystore.p12
  fi
}

function retry_while() {
    local cmd="${1:?cmd is missing}"
    local retries="${2:-24}"
    local sleep_time="${3:-5}"
    local return_value=1

    read -r -a command <<< "$cmd"
    for ((i = 1 ; i <= retries ; i+=1 )); do
        "${command[@]}" && return_value=0 && break
        sleep "$sleep_time"
    done
    return $return_value
}
