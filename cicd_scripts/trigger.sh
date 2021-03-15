#! /bin/bash

# cicd_scripts/trigger.sh

setup() {
    # Load our script file.
    source ./cicd_scripts/logger.sh
}

addAttribute(){
    echo "$skey"
    if [ -z $skeys ]
    then
        k=$(echo "$1")
        v=$(echo "$2")
    else
        k=$(echo "|$1")
        v=$(echo "|$2")
    fi
    skeys=$(echo "$skeys$k")
    svals=$(echo "$svals$v")
}

buildJson(){
    s="$skeys
$svals"
    path=$1
    parms=$(jq -Rn --arg path "$path" '
    setpath([$path];
    ( input | split("|") ) as $keys |
    ( input | split("|") ) as $vals |
    [[$keys, $vals] | transpose[] | {key:.[0],value:.[1]}] | from_entries)
    ' <<<"$s")
    jq . <<< "$parms"
}

parse_response(){
    write_log "INFO" "Parsing Trigger Response"
    tmp_fil=$1
    export RESPONSE_MESSAGE=$( jq ".message" < "$tmp_fil" | sed 's/\"//g' )
    if [ $(echo "|$RESPONSE_MESSAGE|") = "|null|" ]
    then
        export workflow_number=$( jq ".number" < "$tmp_fil" | sed 's/\"//g' )
        export workflow_state=$( jq ".state" < "$tmp_fil" | sed 's/\"//g' )
        export workflow_id=$( jq ".id" < "$tmp_fil" | sed 's/\"//g' )
        export workflow_created_at=$( jq ".created_at" < "$tmp_fil" | sed 's/\"//g' )
        rm "$tmp_fil"
        write_log "INFO" "      Workflow Number : $workflow_number"
        write_log "INFO" "      Triggered at    : $workflow_created_at"
        write_log "INFO" "      State           : $workflow_state"
        
        if [ $(echo "|$CI|") = "|1|" ]
        then
            if [ $workflow_number -eq 136 ]
            then
                echo "$workflow_number"
            else
                echo "$workflow_state"
            fi
        fi
    else
        rm "$tmp_fil"
        case "$RESPONSE_MESSAGE" in
            "Permission denied")
                if [ $(echo "|$CI|") = "||" ] || [ $(echo "|$CI|") = "|0|" ]
                then
                    write_log "ERROR" "Trigger Response Found : $1" "header"
                    write_log "ERROR" '   Please set $CIRCLE_TOKEN environment variable' "footer"
                else
                    echo "ERROR"
                fi
                ;;
            "Project not found")
                if [ $(echo "|$CI|") = "||" ] || [ $(echo "|$CI|") = "|0|" ]
                then
                    write_log "ERROR" "Trigger Response Found : $1" "header"
                    write_log "ERROR" '   Please set $CIRCLE_TOKEN environment variable' "footer"
                else
                    echo "ERROR"
                fi
                ;;
        esac  
    fi
}

trigger(){
    tmp_fil=$(openssl rand -hex 8)
    header_result_file=$(openssl rand -hex 8)
    
    cirlce_ci_url="https://circleci.com/api/v2/project/"$2"/"$3"/"$4"/pipeline"
    write_log "INFO" "Triggering Workflow at : $cirlce_ci_url"
    
    addAttribute "environment" "$1"
    data=$(buildJson "parameters")
    write_log "INFO" "Posting with data $data"
    curl -X POST \
        --silent \
        --output "$tmp_fil" \
        --dump-header "$header_result_file" \
        --header "Circle-Token: $5" \
        --header "Content-Type: application/json" \
        --header 'Accept: application/json' \
        --data "$data" \
        $cirlce_ci_url
    
    export curl_response_is_good="|$(cat $header_result_file | grep "HTTP/1.1" | grep "201")|"
    export header_result=$(cat $header_result_file | grep "HTTP/1.1")
    rm $header_result_file
    if [ "$curl_response_is_good" != "||" ]
    then
        parse_response "$tmp_fil"
    else
        rm $tmp_fil
        if [ $(echo "|$CI|") = "|1|" ]
        then
            echo "$header_result"
        else
            write_log "ERROR" "Curl Failed" "header"
            write_log "ERROR" "$header_result" "footer"
        fi
    fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    setup
    trigger $@
fi