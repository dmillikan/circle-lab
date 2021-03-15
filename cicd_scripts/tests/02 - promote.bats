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
}

@test 'promote.sh - 1 : Get Next Env - Dev' {
    ENVIRONMENT="dev"
    get_next_environment
    [ "$ENVIRONMENT" = "preprod" ]
}

@test 'promote.sh - 2 : Get Next Env - Preprod' {
    ENVIRONMENT="preprod"
    get_next_environment
    [ "$ENVIRONMENT" = "prod" ]
}

@test 'promote.sh - 3 : Get Next Env - Prod' {
    ENVIRONMENT="prod"
    get_next_environment
    [ "$ENVIRONMENT" = "terminate" ]
}

@test 'promote.sh - 4 : Get Next Env - Other' {
    ENVIRONMENT="other"
    get_next_environment
    [ "$ENVIRONMENT" = "terminate" ]
}