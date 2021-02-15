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
    signature="d6445d9748fb0e551d0bc85f1451f793eea33b76a2667889be2273464ae20ac7"
    export outfile="$(openssl rand -hex 8).json"
    result=$(build_workflow_file)
    outfile_signature=$(openssl sha256 < "$outfile")
    echo "Outfile            : $outfile"
    cat $outfile
    echo "Outfile Signature  : $outfile_signature"
    echo "Expected Signature : $signature"
    [ "$outfile_signature" == "$signature" ]
    rm $manifest_file
    rm $order_file
    rm $outfile
}

@test 'workflow.sh - 2 : First Workflow Advancement' {
    signature="47ae8189b5c95d92606c52fa52d653948c18f6c2a46a68c46355effc15d5aebc"
    expected_position="device-gql-sls"
    outfile="$(openssl rand -hex 8).json"
    build_workflow_file
    result=$(advance_workflow)
    outfile_signature=$(openssl sha256 < "$outfile")
    echo "Outfile            : $outfile"
    cat $outfile
    echo "Outfile Signature  : $outfile_signature"
    echo "Expected Signature : $signature"
    [ "$outfile_signature" == "$signature" ]
    echo "Current Position   : $result"
    echo "Expected Position  : $expected_position"
    [ "$result" == "$expected_position" ]
    rm $manifest_file
    rm $order_file
    rm $outfile
}

@test 'workflow.sh - 3 : Final Workflow Advancement' {
    signature="4c9d3a85dae88634468e117621ec38af018a629c2c7a58be69ff20d6a2e617ea"
    expected_position="terminate"
    outfile="$(openssl rand -hex 8).json"
    build_workflow_file
    result=$(advance_workflow)
    result=$(advance_workflow)
    result=$(advance_workflow)
    result=$(advance_workflow)
    result=$(advance_workflow)
    outfile_signature=$(openssl sha256 < "$outfile")
    echo "Outfile            : $outfile"
    cat $outfile
    echo "Outfile Signature  : $outfile_signature"
    echo "Expected Signature : $signature"
    [ "$outfile_signature" == "$signature" ]
    echo "Current Position   : $result"
    echo "Expected Position  : $expected_position"
    [ "$result" == "$expected_position" ]
    rm $manifest_file
    rm $order_file
    rm $outfile
}