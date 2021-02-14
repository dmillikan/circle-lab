#! /bin/bash

# cicd_scripts/controller.sh
setup() {
    # Load our script file.
    source ./cicd_scripts/logger.sh
    source ./cicd_scripts/promote.sh
    source ./cicd_scripts/version.sh
    source ./cicd_scripts/trigger.sh
}

controller(){
    setup
    write_log "INFO" "****************************************************************************************************"
    write_log "INFO" "controller.sh Starting"
    write_log "INFO" "****************************************************************************************************"
    get_version
    get_build
    IS_DEV_BUILD="true"
    bump_version
    unset IS_DEV_BUILD
    bump_version minor rc

}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    controller
fi