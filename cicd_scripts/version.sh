#! /bin/bash

# cicd_scripts/version.sh
setup() {
    # Load our script file.
    source ./cicd_scripts/logger.sh
    source ./cicd_scripts/semver.sh
}

bump_version(){
    source ./cicd_scripts/semver.sh
    
    if [ -n "$IS_DEV_BUILD" ]
    then
        write_log "INFO" "Dev Build"
        NEW_VERSION=$(semver bump build $BUILD_NUM $PRIOR_VERSION)
    else
        write_log "INFO" "Request for $1 bump from prior version $PRIOR_VERSION"
        NEW_VERSION=$(semver bump $1 $PRIOR_VERSION)

        case $2 in
            "rc")
                NEW_VERSION=$(semver bump prerel rc $NEW_VERSION)
                NEW_VERSION=$(semver bump build $BUILD_NUM $NEW_VERSION)
            ;;
            "release")
                NEW_VERSION=$(semver bump release $NEW_VERSION)
                save_version_file
            ;;
            *)
                NEW_VERSION=$(semver bump build $BUILD_NUM $PRIOR_VERSION)
            ;;
        esac
    fi
    
    write_log "INFO" "New Version = $NEW_VERSION"
}

save_version_file(){
    write_log "INFO" "Saving new version $NEW_VERSION to file $VERSION_FILE"
    echo $NEW_VERSION > $VERSION_FILE
}

get_build(){
    write_log "INFO" "Determining Build"
    if [ -n "$CIRCLE_BUILD_NUM" ]
    then
        write_log "INFO" "  Using CIRCLE_BUILD_NUM : $CIRCLE_BUILD_NUM"
        BUILD_NUM=build-$CIRCLE_BUILD_NUM
    else
        write_log "INFO" "  Using commit hash"
        BUILD_NUM=commit-$(git rev-parse HEAD | sed -e 's/^\(.\{7\}\).*/\1/')
    fi

    write_log "INFO" "  Build Num = $BUILD_NUM"
}

get_version(){
    write_log "INFO" "Determining Version"
    if [ -n "$PRIOR_VERSION" ]
    then
        write_log "INFO" "  Envar value PRIOR_VERSION Found: $PRIOR_VERSION"
    else
        write_log "INFO" "  Envar value PRIOR_VERSION not found"
        write_log "INFO" "  Searching for ver file"
        if [ -e "$VERSION_FILE" ]
        then
            write_log "INFO" "  Version file found, reading input"
            PRIOR_VERSION=$( cat $VERSION_FILE )
        else
            VERSION_FILE=$(openssl rand -hex 8).version
            write_log "INFO" "  Version file not found will init: $VERSION_FILE"
            echo "0.0.0" > $VERSION_FILE
            PRIOR_VERSION=$( cat $VERSION_FILE )
        fi
    fi

    write_log "INFO" "  Prior Version = $PRIOR_VERSION"
}

validate_input(){
    write_log "INFO" "Validaing input based on semver bump options"
    write_log "INFO" "      vershion.sh (major|minor|patch) (rc|release)"
    case $1 in
        "major")
            write_log "INFO" "  Bump: $1"
        ;;
        "minor")
            write_log "INFO" "  Bump: $1"
        ;;
        "patch")
            write_log "INFO" "  Bump: $1"
        ;;
        "rc")
            write_log "ERROR" "Bump Option Detected: $1"
            write_log "ERROR" "Please use with (major|minor|patch) $1"
            exit 1
        ;;
        "release")
            write_log "ERROR" "Bump Option Dectected: $1"
            write_log "ERROR" "Please use with (major|minor|patch) $1"
            exit 1
        ;;
        *)
            write_log "INFO" "  Dev Build Assumed"
            IS_DEV_BUILD=true
    esac

    case $2 in
        "rc")
            write_log "INFO" "  Bump Option Detected: $2"
        ;;
        "release")
            write_log "INFO" "  Bump Option Detected: $2"
        ;;

    esac

    write_log "INFO" "  Will bump with command: semver bump $1 $2"
}

version(){
    setup
    validate_input $@
    get_version
    get_build
    bump_version $@
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    version $@
fi