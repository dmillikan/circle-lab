#! /bin/bash

# cicd_scripts/promote.sh

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

promote(){
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
    export ENVIRONMENT
}

trigger(){
    tmp_fil=$(openssl rand -hex 8)
    header_result_file=$(openssl rand -hex 8)
    
    cirlce_ci_url="https://circleci.com/api/v2/project/"$2"/"$3"/"$4"/pipeline"
    write_log "INFO" "Triggering Workflow at : $cirlce_ci_url"
    
    curl -X POST \
        --silent \
        --output "$tmp_fil" \
        --dump-header "$header_result_file" \
        --header "Circle-Token: $5" \
        --header "Content-Type: application/json" \
        --header 'Accept: application/json' \
        --data '{
            "parameters": {
            "environment": "'"$1"'"
            }
        }' \
        $cirlce_ci_url
    
    export curl_response_is_good="|$(cat $header_result_file | grep "HTTP/1.1" | grep "201")|"
    export header_result=$(cat $header_result_file | grep "HTTP/1.1")
    rm $header_result_file
    if [ "$curl_response_is_good" != "||" ]
    then
        parse_response "$tmp_fil"
    else
        rm $tmp_fil
        write_log "ERROR" "Curl Failed" "header"
        write_log "ERROR" "$header_result" "footer"
    fi
}

parse_response(){
    write_log "INFO" "Parsing Trigger Response"
    export RESPONSE_MESSAGE=$( jq ".message" < "$tmp_fil" | sed 's/\"//g' )
    if [ -n $RESPONSE_MESSAGE ]
    then
        export workflow_number=$( jq ".number" < "$tmp_fil" | sed 's/\"//g' )
        export workflow_state=$( jq ".state" < "$tmp_fil" | sed 's/\"//g' )
        export workflow_id=$( jq ".id" < "$tmp_fil" | sed 's/\"//g' )
        export workflow_created_at=$( jq ".created_at" < "$tmp_fil" | sed 's/\"//g' )
        rm "$tmp_fil"
        write_log "INFO" "      Workflow Number : $workflow_number"
        write_log "INFO" "      Triggered at    : $workflow_created_at"
        write_log "INFO" "      State           : $workflow_state"
    else
        rm "$tmp_fil"
        case $RESPONSE_MESSAGE in
            "Permission denied")
                write_log "ERROR" "Trigger Response Found : $1" "header"
                write_log "ERROR" '   Please set $CIRCLE_TOKEN environment variable' "footer"
                ;;
            "Project not found")
                write_log "ERROR" "Trigger Response Found : $1" "header"
                write_log "ERROR" '   Please set $CIRCLE_TOKEN environment variable' "footer"
                ;;
        esac
    fi

}

set_defaults(){
    export ENVIRONMENT="dev"
    export REPO_CODE="gh"
    export CIRCLE_PROJECT_USERNAME="dmillikan"
    export CIRCLE_PROJECT_REPONAME="circle-lab"
    
}

main(){
    if [ "$CI" ]
    then
        export ENVIRONMENT=$1
        export REPO_CODE=$2
    else
        write_log "INFO" "Setting defaults"
        set_defaults
    fi

    write_log "INFO" "Environment before promotion is   : $ENVIRONMENT"
    promote
    write_log "INFO" "Environment after promotion is    : $ENVIRONMENT"
    # export > a
    # cat a
    if [ "$ENVIRONMENT" != "terminate" ]
    then
        write_log "INFO" "Will trigger workflow for" "$ENVIRONMENT"
        trigger "$ENVIRONMENT" "$REPO_CODE" "$CIRCLE_PROJECT_USERNAME" "$CIRCLE_PROJECT_REPONAME" "$CIRCLE_TOKEN"
    fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    main
fi