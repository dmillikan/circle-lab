#! /bin/bash
# move the head
promote(){
    case $ENVIRONMENT in
        dev)
            ENVIRONMENT="preprod"
        ;;
        preprod)
            ENVIRONMENT="prod"
        ;;
        *)
            ENVIRONMENT="terminate"
        ;;
    esac
    export ENVIRONMENT
}

trigger(){
    response=$(
        curl -X POST \
        --header "Circle-Token: $5" \
        --header "Content-Type: application/json" \
        --header 'Accept: application/json' \
        --data '{
            "parameters": {
            "environment": "'"$1"'"
            }
        }' \
        https://circleci.com/api/v2/project/"$2"/"$3"/"$4"/pipeline
    )
    echo "$response"
}

set_defaults(){
    export ENVIRONMENT="dev"
    export REPO_CODE="gh"
    export CIRCLE_PROJECT_USERNAME="dmillikan"
    export CIRCLE_PROJECT_REPONAME="circle-lab"
    
}
if [ "$CI" ]
then
    export ENVIRONMENT=$1
    export REPO_CODE=$2
else
    echo "Setting defaults"
    set_defaults
fi

echo "Environment before promotion is   :" "$ENVIRONMENT"
promote
echo "Environment after promotion is    :" "$ENVIRONMENT"
# export > a
# cat a
if [ "$ENVIRONMENT" != "terminate" ]
then
    echo "Will trigger workflow for" "$ENVIRONMENT"
    trigger "$ENVIRONMENT" "$REPO_CODE" "$CIRCLE_PROJECT_USERNAME" "$CIRCLE_PROJECT_REPONAME" "$CIRCLE_TOKEN"
fi
