# Runs prior to every test
setup() {
    # Load our script file.
    source ./cicd_scripts/version.sh
    CI=1
    unset NEW_VERSION
    unset PRIOR_VERSION
    VERSION_FILE=$(openssl rand -hex 8).version
    echo "0.0.0" > $VERSION_FILE
}

@test 'version.sh  - File  -  1: Test Patch Release' {
    expected="0.0.1"
    version patch release
    filver=$(cat $VERSION_FILE)
    [ "$NEW_VERSION" == "$expected" ]
    [ "$filver" == "$expected" ]
    rm $VERSION_FILE
}

@test 'version.sh  - File  -  2: Test Minor Release' {
    expected="0.1.0"
    version minor release
    filver=$(cat $VERSION_FILE)
    [ "$NEW_VERSION" == "$expected" ]
    [ "$filver" == "$expected" ]
    rm $VERSION_FILE
}

@test 'version.sh  - File  -  3: Test Major Release' {
    expected="1.0.0"
    version major release
    filver=$(cat $VERSION_FILE)
    [ "$NEW_VERSION" == "$expected" ]
    [ "$filver" == "$expected" ]
    rm $VERSION_FILE
}

@test 'version.sh  - File  -  4: Test Patch RC' {
    # get new version
    version patch rc
    result=$(echo $NEW_VERSION | grep "0.0.1-rc+commit-" | wc -l)
    [ $result -eq 1 ]
    result=$(cat $VERSION_FILE)
    [ "$result" == "0.0.0" ]
    rm $VERSION_FILE
}

@test 'version.sh  - File  -  5: Test Minor RC' {
    # get new version
    version minor rc
    result=$(echo $NEW_VERSION | grep "0.1.0-rc+commit-" | wc -l)
    [ $result -eq 1 ]
    result=$(cat $VERSION_FILE)
    [ "$result" == "0.0.0" ]
    rm $VERSION_FILE
}

@test 'version.sh  - File  -  6: Test Major RC' {
    # get new version
    version major rc
    result=$(echo $NEW_VERSION | grep "1.0.0-rc+commit-" | wc -l)
    [ $result -eq 1 ]
    result=$(cat $VERSION_FILE)
    [ "$result" == "0.0.0" ]
    rm $VERSION_FILE
}

@test 'version.sh  - File  -  7: Test Commit' {
    # get new version
    version
    result=$(echo $NEW_VERSION | grep "0.0.0+commit-" | wc -l)
    [ $result -eq 1 ]
    result=$(cat $VERSION_FILE)
    [ "$result" == "0.0.0" ]
    rm $VERSION_FILE
}

@test 'version.sh  - File  -  8: Test Patch Release - Complex' {
    expected="0.0.1"
    echo "0.0.0-rc+commit-BATS" > $VERSION_FILE
    version patch release
    filver=$(cat $VERSION_FILE)
    [ "$NEW_VERSION" == "$expected" ]
    [ "$filver" == "$expected" ]
    rm $VERSION_FILE
}

@test 'version.sh  - File  -  9: Test Minor Release - Complex' {
    expected="0.1.0"
    echo "0.0.0-rc+commit-BATS" > $VERSION_FILE
    version minor release
    filver=$(cat $VERSION_FILE)
    [ "$NEW_VERSION" == "$expected" ]
    [ "$filver" == "$expected" ]
    rm $VERSION_FILE
}

@test 'version.sh  - File  - 10: Test Major Release - Complex' {
    expected="1.0.0"
    echo "0.0.0-rc+commit-BATS" > $VERSION_FILE
    version major release
    filver=$(cat $VERSION_FILE)
    [ "$NEW_VERSION" == "$expected" ]
    [ "$filver" == "$expected" ]
    rm $VERSION_FILE
}

@test 'version.sh  - Envar -  1: Test Patch Release' {
    PRIOR_VERSION="0.0.0"
    version patch release
    [ "$NEW_VERSION" == "0.0.1" ]
    rm $VERSION_FILE
}

@test 'version.sh  - Envar -  2: Test Minor Release' {
    # prepare environment
    PRIOR_VERSION="0.0.0"
    version minor release
    [ "$NEW_VERSION" == "0.1.0" ]
    rm $VERSION_FILE
}

@test 'version.sh  - Envar -  3: Test Major Release' {
    # prepare environment
    PRIOR_VERSION="0.0.0"
    version major release
    [ "$NEW_VERSION" == "1.0.0" ]
    rm $VERSION_FILE
}

@test 'version.sh  - Envar -  4: Test Patch RC' {
    # prepare environment
    PRIOR_VERSION="0.0.0"
    # get new version
    version patch rc
    result=$(echo $NEW_VERSION | grep "0.0.1-rc+commit-" | wc -l)
    [ $result -eq 1 ]
    rm $VERSION_FILE
}

@test 'version.sh  - Envar -  5: Test Minor RC' {
    # prepare environment
    PRIOR_VERSION="0.0.0"
    # get new version
    version minor rc
    result=$(echo $NEW_VERSION | grep "0.1.0-rc+commit-" | wc -l)
    [ $result -eq 1 ]
    rm $VERSION_FILE
}

@test 'version.sh  - Envar -  6: Test Major RC' {
    # prepare environment
    PRIOR_VERSION="0.0.0"       
    # get new version
    version major rc
    result=$(echo $NEW_VERSION | grep "1.0.0-rc+commit-" | wc -l)
    [ $result -eq 1 ]
    rm $VERSION_FILE
}

@test 'version.sh  - Envar -  7: Test Commit' {
    # prepare environment
    PRIOR_VERSION="0.0.0"
    # get new version
    version
    result=$(echo $NEW_VERSION | grep "0.0.0+commit-" | wc -l)
    [ $result -eq 1 ]
    rm $VERSION_FILE
}

@test 'version.sh  - Envar -  8: Test Patch Release - Complex' {
    # prepare environment
    PRIOR_VERSION="0.0.0-rc+commit-BATS"
    version patch release
    [ "$NEW_VERSION" == "0.0.1" ]
    rm $VERSION_FILE
}

@test 'version.sh  - Envar -  9: Test Minor Release - Complex' {
    # prepare environment
    PRIOR_VERSION="0.0.0-rc+commit-BATS"
    version minor release
    [ "$NEW_VERSION" == "0.1.0" ]
    rm $VERSION_FILE
}

@test 'version.sh  - Envar - 10: Test Major Release - Complex' {
    # prepare environment
    PRIOR_VERSION="0.0.0-rc+commit-BATS"
    version major release
    [ "$NEW_VERSION" == "1.0.0" ]
    rm $VERSION_FILE
}

@test 'version.sh  - Both  -  1: Test File and Envar' {
    # prepare environment
    PRIOR_VERSION="1.0.0"
    FILE_VERSION=$(cat $VERSION_FILE)
    [ "$PRIOR_VERSION" = "1.0.0" ]
    [ "$FILE_VERSION" = "0.0.0" ]

    # Envar overrides file
    version major release
    FILE_VERSION=$(cat $VERSION_FILE)
    [ "$NEW_VERSION" = "2.0.0" ]
    [ "$FILE_VERSION" = "2.0.0" ]

    # Check for idempotency
    version major release
    FILE_VERSION=$(cat $VERSION_FILE)
    [ "$NEW_VERSION" = "2.0.0" ]
    [ "$FILE_VERSION" = "2.0.0" ]

    # Empty the envar
    unset PRIOR_VERSION
    FILE_VERSION=$(cat $VERSION_FILE)
    [ -z "$PRIOR_VERSION" ]
    [ "$FILE_VERSION" = "2.0.0" ]
    
    version major release
    FILE_VERSION=$(cat $VERSION_FILE)
    [ "$NEW_VERSION" == "3.0.0" ]
    [ "$FILE_VERSION" == "3.0.0" ]

    PRIOR_VERSION="9.0.0"
    FILE_VERSION="0.0.1"
    [ $PRIOR_VERSION == "9.0.0" ]
    [ "$FILE_VERSION" == "0.0.1" ]
    version major release
    FILE_VERSION=$(cat $VERSION_FILE)
    [ "$NEW_VERSION" == "10.0.0" ]
    [ "$FILE_VERSION" == "10.0.0" ]
    rm $VERSION_FILE
}

