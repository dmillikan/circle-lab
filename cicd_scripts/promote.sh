#! /bin/bash

# cicd_scripts/promote.sh

setup() {
    # Load our script file.
    source ./cicd_scripts/logger.sh
    source ./cicd_scripts/trigger.sh  
}

get_next_environment(){
    case $ENVIRONMENT in
        dev)
            ENVIRONMENT="preprod"
        ;;
        preprod)
            ENVIRONMENT="prod"
        ;;
        *)
            ENVIRONMENT="terminate"
        ;;
    esac
    echo $ENVIRONMENT
}

promote(){
    setup
    write_log "INFO" "Environment before promotion is   : $ENVIRONMENT"
    ENVIRONMENT=$(get_next_environment)
    write_log "INFO" "Environment after promotion is    : $ENVIRONMENT"
    if [ "$ENVIRONMENT" != "terminate" ]
    then
        write_log "INFO" "Will trigger workflow for" "$ENVIRONMENT"
        trigger "$ENVIRONMENT" "$REPO_CODE" "$CIRCLE_PROJECT_USERNAME" "$CIRCLE_PROJECT_REPONAME" "$CIRCLE_TOKEN"
    fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
# ORB_TEST_ENV="bats-core"
# if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
#     promote
# fi