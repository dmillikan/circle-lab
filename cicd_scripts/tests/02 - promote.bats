# Runs prior to every test
setup() {
    # Check for jq
    if [ ! $(which jq) ]
    then
        echo "need to install jq"
        brew install jq
    fi
    # Load our script file.
    source ./cicd_scripts/promote.sh
    CI=1
    ENVIRONMENT="dev"
    REPO_CODE="gh"
    CIRCLE_PROJECT_USERNAME="dmillikan"
    CIRCLE_PROJECT_REPONAME="circle-lab"

    CIRCLE_TOKEN=$CIRCLE_TOKEN_BAK

}

@test 'promote.sh  - Function  -  1: Get Next Env - Dev' {
    ENVIRONMENT="dev"
    result=$(get_next_environment)
    [ "$result" = "preprod" ]
}

@test 'promote.sh  - Function  -  2: Get Next Env - Preprod' {
    ENVIRONMENT="preprod"
    result=$(get_next_environment)
    [ "$result" = "prod" ]
}

@test 'promote.sh  - Function  -  3: Get Next Env - Prod' {
    ENVIRONMENT="prod"
    result=$(get_next_environment)
    [ "$result" = "terminate" ]
}

@test 'promote.sh  - Function  -  4: Get Next Env - Other' {
    ENVIRONMENT="other"
    result=$(get_next_environment)
    [ "$result" = "terminate" ]
}

@test 'promote.sh  - Function  -  5: Parse Response - Denied' {
    tmp_fil=$(openssl rand -hex 8)
    echo '{"message":"Permission denied"}' > "$tmp_fil"
    result=$(parse_response "$tmp_fil")
    [ "$result" = "ERROR" ]
}

@test 'promote.sh  - Function  -  6: Parse Response - Success' {
    tmp_fil=$(openssl rand -hex 8)
    echo '{
    "number": 136,
    "state": "pending",
    "id": "d19c5b7b-b8ee-431e-a497-10c63daf7de9",
    "created_at": "2021-01-01"
    }' > "$tmp_fil"
    result=$(parse_response "$tmp_fil")
    [ "$result" = "136" ]
}

@test 'promote.sh  - Main      -  7: Trigger - Sucess' {
    if [ $(echo "|$CIRCLE_TOKEN|") == "||" ]
    then
        echo 'Please set $CIRCLE_TOKEN envar'
        [ $(echo "|$CIRCLE_TOKEN|") != "||" ]
    fi
    result=$(promote)
    [ "$result" = "pending" ]
}

@test 'promote.sh  - Main      -  8: Trigger - Fail - Repo' {
    if [ $(echo "|$CIRCLE_TOKEN|") == "||" ]
    then
        echo 'Please set $CIRCLE_TOKEN envar'
        [ $(echo "|$CIRCLE_TOKEN|") != "||" ]
    fi
    unset REPO_CODE
    result=$(promote)
    [ $(echo "$result" | grep "404" | wc -l) -eq 1 ]

}

@test 'promote.sh  - Main      -  9: Trigger - Fail - Project' {
    if [ $(echo "|$CIRCLE_TOKEN|") == "||" ]
    then
        echo 'Please set $CIRCLE_TOKEN envar'
        [ $(echo "|$CIRCLE_TOKEN|") != "||" ]
    fi
    REPO_CODE="gh"
    unset CIRCLE_PROJECT_USERNAME
    CIRCLE_PROJECT_REPONAME="circle-lab"
    result=$(promote)
    
    [ $(echo "$result" | grep "404" | wc -l) -eq 1 ]
}

@test 'promote.sh  - Main     -  10: Trigger - Fail - Repo' {
    if [ $(echo "|$CIRCLE_TOKEN|") == "||" ]
    then
        echo 'Please set $CIRCLE_TOKEN envar'
        [ $(echo "|$CIRCLE_TOKEN|") != "||" ]
    fi
    REPO_CODE="gh"
    CIRCLE_PROJECT_USERNAME="dmillikan"
    unset CIRCLE_PROJECT_REPONAME
    result=$(promote)
    
    [ $(echo "$result" | grep "404" | wc -l) -eq 1 ]
}