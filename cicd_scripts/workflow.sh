#! /bin/bash

# cicd_scripts/workflow.sh

setup() {
    # Load our script file.
    source ./cicd_scripts/logger.sh
}

build_workflow_file(){
    echo '
    {
        "master_workflow": []
    }' > "$outfile"
    
    for order_item in $(cat "$order_file" | jq .packages | jq -r 'keys_unsorted[]')
    do
        for manifest_item in $(jq -r .[] < "$manifest_file")
        do
            if [ "$order_item" == "$manifest_item" ]
            then
                export ORDER_ITEM=$(echo $order_item)
                echo $(cat "$outfile" | jq '.master_workflow |= .+ [$ENV.ORDER_ITEM]') > "$outfile"
                echo $(cat "$outfile" | jq '.future_position |= .+ [$ENV.ORDER_ITEM]') > "$outfile"
            fi
        done
    done
    current_position=$(cat "$outfile" | jq -r '.future_position[0]')
    echo $(cat "$outfile" | jq '. |= .+ { "current_position": $ENV.current_position }') > "$outfile"
    echo $(cat "$outfile" | jq 'del(.future_position[0])') > "$outfile"

}

advance_workflow(){
    if [ $(cat "$outfile" | jq '.future_position[0]') == "null" ]
    then
        future_position="terminate"
        build_workflow_file
    else
        current_position=$(cat "$outfile" | jq -r '.current_position')
        future_position=$(cat "$outfile" | jq -r '.future_position[0]')
        echo $(cat "$outfile" | jq 'del(.current_position)') > "$outfile" 
        echo $(cat "$outfile" | jq '. |= .+ { "current_position": $ENV.future_position }') > "$outfile"
        echo $(cat "$outfile" | jq 'del(.future_position[0])') > "$outfile"  

        if [ -z $CI ]
        then
            CI=0
        fi
        if [ $CI -eq 1 ]
        then
            echo "$future_position"
        fi

        write_log "INFO" "Advanced From     : $current_position"
        write_log "INFO" "Advanced to       : $future_position"
    fi 
}

main(){
    setup
    write_log "INFO" "Starting Workflow Script" "header"
    case $1 in
        "build_workflow_file")
            build_workflow_file
            ;;
         "advance_workflow")
            advance_workflow
            ;;
    esac
}

ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    main $@
fi