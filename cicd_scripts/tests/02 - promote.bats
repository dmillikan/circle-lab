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

@test 'promote.sh  - Function  -  1: Promote Dev' {
    ENVIRONMENT="dev"
    result=$(promote)
    [ "$result" = "preprod" ]
}

@test 'promote.sh  - Function  -  2: Promote Preprod' {
    ENVIRONMENT="preprod"
    result=$(promote)
    [ "$result" = "prod" ]
}

@test 'promote.sh  - Function  -  3: Promote Prod' {
    ENVIRONMENT="prod"
    result=$(promote)
    [ "$result" = "terminate" ]
}

@test 'promote.sh  - Function  -  4: Promote Other' {
    ENVIRONMENT="other"
    result=$(promote)
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
    result=$(main)
    [ "$result" = "pending" ]
}

@test 'promote.sh  - Main      -  8: Trigger - Fail - Repo' {
    if [ $(echo "|$CIRCLE_TOKEN|") == "||" ]
    then
        echo 'Please set $CIRCLE_TOKEN envar'
        [ $(echo "|$CIRCLE_TOKEN|") != "||" ]
    fi
    unset REPO_CODE
    result=$(main)
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
    result=$(main)
    
    [ $(echo "$result" | grep "404" | wc -l) -eq 1 ]
}

@test 'promote.sh  - Main      -  10: Trigger - Fail - Repo' {
    if [ $(echo "|$CIRCLE_TOKEN|") == "||" ]
    then
        echo 'Please set $CIRCLE_TOKEN envar'
        [ $(echo "|$CIRCLE_TOKEN|") != "||" ]
    fi
    REPO_CODE="gh"
    CIRCLE_PROJECT_USERNAME="dmillikan"
    unset CIRCLE_PROJECT_REPONAME
    result=$(main)
    
    [ $(echo "$result" | grep "404" | wc -l) -eq 1 ]
}