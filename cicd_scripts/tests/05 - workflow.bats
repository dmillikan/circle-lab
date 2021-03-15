# Runs prior to every test
setup() {
    # Check for jq
    if [ ! $(which jq) ]
    then
        echo "need to install jq"
        brew install jq
    fi
    # Load our script file.
    source ./cicd_scripts/logger.sh
    source ./cicd_scripts/workflow.sh
    CI=1
    # Prep Default Files
    manifest_file=$(openssl rand -hex 8)
    echo '[
        "celsius-action-engine",
        "celsius-dashboard",
        "data-disc-sls",
        "device-gql-sls",
        "user-gql-sls"
    ]' > $manifest_file

    order_file=$(openssl rand -hex 8)
    echo '{
        "root": "apps",
        "pages": 3,
        "packages": {
            "celsius-data-storage": ["apps/celsius-data-storage/"],
            "data-disc-sls": ["apps/data-disc-sls/"],
            "device-gql-sls": ["apps/device-gql-sls/"],
            "user-gql-sls": ["apps/user-gql-sls"],
            "flespi-sparkplug-converter": ["apps/flespi-sparkplug-converter/"],
            "celsius-action-engine": ["apps/celsius-action-engine"],
            "strapi-infra": ["apps/strapi-infra"],
            "external-rest-api-sls": ["apps/external-rest-api-sls"],
            "celsius-dashboard": ["apps/celsius-dashboard/"]
        }
    }' > $order_file
}

@test 'workflow.sh - 1 : Build Workflow File' {
    export outfile="$(openssl rand -hex 8).json"
    build_workflow_file
    echo "Outfile            : $outfile"
    cat $outfile
    echo $(jq -r '.master_workflow | length' $outfile)
    [ $(jq -r '.master_workflow | length' $outfile) -eq 5 ]
    rm $manifest_file
    rm $order_file
    rm $outfile
}

@test 'workflow.sh - 2 : First Workflow Advancement' {
    expected_position="device-gql-sls"
    outfile="$(openssl rand -hex 8).json"
    build_workflow_file
    advance_workflow
    echo "Outfile            : $outfile"
    cat $outfile
    echo "Current Position   : $future_position"
    echo "Expected Position  : $expected_position"
    [ "$future_position" == "$expected_position" ]
    rm $manifest_file
    rm $order_file
    rm $outfile
}

@test 'workflow.sh - 3 : Final Workflow Advancement' {
    expected_position="terminate"
    outfile="$(openssl rand -hex 8).json"
    build_workflow_file
    advance_workflow
    advance_workflow
    advance_workflow
    advance_workflow
    advance_workflow
    echo "Outfile            : $outfile"
    cat $outfile
    echo "Current Position   : $future_position"
    echo "Expected Position  : $expected_position"
    [ "$future_position" == "$expected_position" ]
    rm $manifest_file
    rm $order_file
    rm $outfile
}