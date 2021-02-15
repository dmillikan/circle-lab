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
    export current_position=$(cat "$outfile" | jq -r '.future_position[0]')
    echo $(cat "$outfile" | jq '. |= .+ { "current_position": $ENV.current_position }') > "$outfile"
    echo $(cat "$outfile" | jq 'del(.future_position[0])') > "$outfile"
    echo "Workflow File Created"
}

advance_workflow(){
    if [ $(cat "$outfile" | jq '.future_position[0]') == "null" ]
    then
        echo "terminate"
        write_log "INFO" "No More to Advance"
    else
        export current_position=$(cat "$outfile" | jq -r '.future_position[0]')
        echo $(cat "$outfile" | jq 'del(.current_position)') > "$outfile" 
        echo $(cat "$outfile" | jq '. |= .+ { "current_position": $ENV.current_position }') > "$outfile"
        echo $(cat "$outfile" | jq 'del(.future_position[0])') > "$outfile"  
        echo "$current_position"
        write_log "INFO" "Advanced to : $current_position"
    fi   
}
