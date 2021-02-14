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
    source ./cicd_scripts/promote.sh
    source ./cicd_scripts/version.sh
    source ./cicd_scripts/trigger.sh

    CI=1
    ENVIRONMENT="dev"
    REPO_CODE="gh"
    CIRCLE_PROJECT_USERNAME="dmillikan"
    CIRCLE_PROJECT_REPONAME="circle-lab"
}

@test 'controller.sh - 1 : Get Next Env - Dev' {
    
    result=$(get_next_environment)
    
    # [ "$result" = "preprod" ]
}