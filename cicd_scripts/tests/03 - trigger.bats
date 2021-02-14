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
    source ./cicd_scripts/trigger.sh
    CI=1
    ENVIRONMENT="dev"
    REPO_CODE="gh"
    CIRCLE_PROJECT_USERNAME="dmillikan"
    CIRCLE_PROJECT_REPONAME="circle-lab"
}
@test 'trigger.sh - 1 : Trigger - Sucess' {
    if [ $(echo "|$CIRCLE_TOKEN|") == "||" ]
    then
        echo 'Please set $CIRCLE_TOKEN envar'
        [ $(echo "|$CIRCLE_TOKEN|") != "||" ]
    fi
    result=$(trigger $ENVIRONMENT $REPO_CODE $CIRCLE_PROJECT_USERNAME $CIRCLE_PROJECT_REPONAME $CIRCLE_TOKEN)
    [ "$result" = "pending" ]
}

@test 'trigger.sh - 2 : Parse Response - Denied' {
    tmp_fil=$(openssl rand -hex 8)
    echo '{"message":"Permission denied"}' > "$tmp_fil"
    result=$(parse_response "$tmp_fil")
    [ "$result" = "ERROR" ]
}

@test 'trigger.sh - 3 : Parse Response - Success' {
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

@test 'trigger.sh - 4 : Trigger - Fail - Repo' {
    if [ $(echo "|$CIRCLE_TOKEN|") == "||" ]
    then
        echo 'Please set $CIRCLE_TOKEN envar'
        [ $(echo "|$CIRCLE_TOKEN|") != "||" ]
    fi
    unset REPO_CODE
    result=$(trigger)
    [ $(echo "$result" | grep "404" | wc -l) -eq 1 ]

}

@test 'trigger.sh - 5 : Trigger - Fail - Project' {
    if [ $(echo "|$CIRCLE_TOKEN|") == "||" ]
    then
        echo 'Please set $CIRCLE_TOKEN envar'
        [ $(echo "|$CIRCLE_TOKEN|") != "||" ]
    fi
    REPO_CODE="gh"
    unset CIRCLE_PROJECT_USERNAME
    CIRCLE_PROJECT_REPONAME="circle-lab"
    result=$(trigger)
    
    [ $(echo "$result" | grep "404" | wc -l) -eq 1 ]
}

@test 'trigger.sh - 6 : Trigger - Fail - Repo' {
    if [ $(echo "|$CIRCLE_TOKEN|") == "||" ]
    then
        echo 'Please set $CIRCLE_TOKEN envar'
        [ $(echo "|$CIRCLE_TOKEN|") != "||" ]
    fi
    REPO_CODE="gh"
    CIRCLE_PROJECT_USERNAME="dmillikan"
    unset CIRCLE_PROJECT_REPONAME
    result=$(trigger)
    
    [ $(echo "$result" | grep "404" | wc -l) -eq 1 ]
}