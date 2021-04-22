#!/usr/bin/env bash
# this script builds via Ant (inside Docker container) - assumes that Docker daemon exists on the instance

# global variables
# VERSION="${1-unspecified}"
BUILD_CONTAINER_IMAGE="${BUILD_CONTAINER_IMAGE:-723692602888.dkr.ecr.eu-north-1.amazonaws.com/wildfly18-ant-cloudhsm-jdk8:18.0.1.1}"
BUILD_CONTAINER_COMMAND="${BUILD_CONTAINER_COMMAND:-ant -q -Dappserver.home=/opt/wildfly -Dappserver.type=jboss -Dappserver.subtype=jbosseap6 -Dejbca.productionmode=true clean build clientToolBox}"
SCRIPT_PATH="$( cd "$(dirname "$0")" || exit ; pwd -P )"

# shellcheck source=scripts/helper_libs.sh
. "${SCRIPT_PATH}/scripts/helper_libs.sh"
  test $? -ne 0 &&\
    echo "failed loading helper libs from '/scripts/helper_libs.sh'" &&\
    exit 1

run_build() {
  log "running build via Ant with command ${BUILD_CONTAINER_COMMAND} - inside Docker container with image ${BUILD_CONTAINER_IMAGE}"
  docker run -u root --rm -v "$(pwd)":/opt/ejbca -w /opt/ejbca ${BUILD_CONTAINER_IMAGE} ${BUILD_CONTAINER_COMMAND}
    check $? 0 "failed to build via Ant (inside Docker container)"
}

# main
check_docker_installed
run_build

# done
log "done"
