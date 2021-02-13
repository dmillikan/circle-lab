#! /bin/bash

# cicd_scripts/controller.sh

write_log(){
    if [ $1 = "ERROR" ]
    then
        if [ $3 = "header" ]
        then
            echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        fi
        echo "X     $1:     $2"
        if [ $3 = "footer" ]
        then
            echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            echo "script is terminating"
            exit 1
        fi
    else
        echo "$1:       $2"
    fi
}



main(){
    write_log "INFO" "****************************************************************************************************"
    write_log "INFO" "controller.sh Starting"
    write_log "INFO" "****************************************************************************************************"
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    main
fi