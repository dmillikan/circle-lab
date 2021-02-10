#! /bin/bash

promote() {
    case $ENVIRONMENT in
        "dev")
            ENVIRONMENT="preprod"
        ;;
        "preprod")
            ENVIRONMENT="prod"
        ;;
    esac
    export ENVIRONMENT
}


trigger() {

response=$(
    curl -X POST \
    --verbose \
    --header "Circle-Token: $5" \
    --header "Content-Type: application/json" \
    --header 'Accept: application/json' \
    --data '{
        "parameters": {
        "environment": "'$1'"
        }
    }' \
    https://circleci.com/api/v2/project/$2/$3/$4/pipeline
)

echo $response
}

set_defaults(){
    export ENVIRONMENT="dev"
    export REPO_CODE="gh"
    export CIRCLE_PROJECT_USERNAME="dmillikan"
    export CIRCLE_PROJECT_REPONAME="circle-lab"
    
}

set_defaults
echo "Environment before promotion is   :" $ENVIRONMENT
promote
echo "Environment after promotion is    :" $ENVIRONMENT
# trigger $ENVIRONMENT $REPO_CODE $CIRCLE_PROJECT_USERNAME $CIRCLE_PROJECT_REPONAME $CIRCLE_TOKEN
