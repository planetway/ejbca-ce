#!/usr/bin/env bash
# helper libs
#
# meant to be source loaded
# e.g.
#   . ./helper_libs.sh

#
# functions
log() {
  pwd=$(pwd)
  echo -e "~ $(date).$(date +%N) ~ ${pwd:0:5}...${pwd: -5} ~> $@" >&2
}

check() {
  if test $1 -ne 0
  then
    log "$2. $3"
    test -s "$3" &&\
      cat "$3"
    exit 1
  fi
}

check_docker_installed() {
  log "smoke test - check if docker is installed"
  if ! docker --version; then
    log "ERROR: Did Docker get installed?"
    exit 1
  fi
}

# done
echo -n