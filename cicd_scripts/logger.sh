#! /bin/bash

# cicd_scripts/logger.sh
write_log(){
    if [ -z $CI ]
    then
        CI=0
    fi
    
    
    case $1 in
        "ERROR")
            bumper="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            gutter="X"
        ;;
        "INFO")
            bumper="------------------------------------------------------------------------------------------"
            gutter=""
        ;; 
    esac

    if [ -z "$3" ]
    then
        case "$3" in
            "header")
                headfoot="$3"
            ;;
            "footer")
                headfoot="$3"
            ;;
                *)
                headfoot="none"
            ;;
        esac
    fi
 
    if [ "$headfoot" = "header" ]
    then
        if [ $CI -eq 0 ]
        then
            echo "$bumper"
        fi
    fi
    
    if [ $CI -eq 0 ]
    then
        echo "$gutter     $1:     $2"
    fi
    
    
    if [ "$headfoot" = "footer" ]
    then
        if [ $CI -eq 0 ]
        then
            echo "$bumper"
        fi
        if [ "$1" == "ERROR" ]
        then
            echo "script is terminating"
            exit 1
        fi
    fi
}
