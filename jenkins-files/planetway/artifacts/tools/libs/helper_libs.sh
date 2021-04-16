#!/bin/bash

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
      echo "$dateString $logLevel [$className] (process:$processId) ${line}"
    done
  else
    echo "$dateString $logLevel [$className] (process:$processId) ${2}"
  fi
}