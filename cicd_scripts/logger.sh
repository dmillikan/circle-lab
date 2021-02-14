#! /bin/bash

# cicd_scripts/logger.sh
write_log(){
    if [ $(echo "|$CI|") = "||" ] || [ $(echo "|$CI|") = "|0|" ]
    then
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
    fi

}
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    write_log
fi