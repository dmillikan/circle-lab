# Runs prior to every test
setup() {
    # Load our script file.
    source ./cicd_scripts/version.sh
    CI=1
    unset NEW_VERSION
    unset PRIOR_VERSION
    rm ver
    [ ! -e ver ]
    echo "0.0.0" > ver
}

@test 'version.sh  - File  -  0: Test Empty Ver File' {
    # prepare environment
    rm ver
    [ ! -e ver ]
    main
    result=$(cat ver)
    [ "$result" == "0.0.0" ]
}

@test 'version.sh  - File  -  1: Test Patch Release' {
    expected="0.0.1"
    result=$(main patch release)
    filver=$(cat ver)
    [ "$result" == "$expected" ] && [ "$filver" == "$expected" ]
}

@test 'version.sh  - File  -  2: Test Minor Release' {
    expected="0.1.0"
    result=$(main minor release)
    filver=$(cat ver)
    [ "$result" == "$expected" ] && [ "$filver" == "$expected" ]
}

@test 'version.sh  - File  -  3: Test Major Release' {
    expected="1.0.0"
    result=$(main major release)
    filver=$(cat ver)
    [ "$result" == "$expected" ] && [ "$filver" == "$expected" ]
}

@test 'version.sh  - File  -  4: Test Patch RC' {
    # get new version
    result=$(echo $(main patch rc) | grep "0.0.1-rc+commit-" | wc -l)
    [ $result -eq 1 ]
    result=$(cat ver)
    [ "$result" == "0.0.0" ]
}

@test 'version.sh  - File  -  5: Test Minor RC' {
    # get new version
    result=$(echo $(main minor rc) | grep "0.1.0-rc+commit-" | wc -l)
    [ $result -eq 1 ]
    result=$(cat ver)
    [ "$result" == "0.0.0" ]
}

@test 'version.sh  - File  -  6: Test Major RC' {
    # get new version
    result=$(echo $(main major rc) | grep "1.0.0-rc+commit-" | wc -l)
    [ $result -eq 1 ]
    result=$(cat ver)
    [ "$result" == "0.0.0" ]
}

@test 'version.sh  - File  -  7: Test Commit' {
    # get new version
    result=$(echo $(main) | grep "0.0.0+commit-" | wc -l)
    [ $result -eq 1 ]
    result=$(cat ver)
    [ "$result" == "0.0.0" ]
}

@test 'version.sh  - File  -  8: Test Patch Release - Complex' {
    expected="0.0.1"
    echo "0.0.0-rc+commit-BATS" > ver
    result=$(main patch release)
    filver=$(cat ver)
    [ "$result" == "$expected" ] && [ "$filver" == "$expected" ]
}

@test 'version.sh  - File  -  9: Test Minor Release - Complex' {
    expected="0.1.0"
    echo "0.0.0-rc+commit-BATS" > ver
    result=$(main minor release)
    filver=$(cat ver)
    [ "$result" == "$expected" ] && [ "$filver" == "$expected" ]
}

@test 'version.sh  - File  - 10: Test Major Release - Complex' {
    expected="1.0.0"
    echo "0.0.0-rc+commit-BATS" > ver
    result=$(main major release)
    filver=$(cat ver)
    [ "$result" == "$expected" ] && [ "$filver" == "$expected" ]
}

@test 'version.sh  - Envar -  1: Test Patch Release' {
    PRIOR_VERSION="0.0.0"
    result=$(main patch release)
    [ "$result" == "0.0.1" ]
}

@test 'version.sh  - Envar -  2: Test Minor Release' {
    # prepare environment
    PRIOR_VERSION="0.0.0"
    result=$(main minor release)
    [ "$result" == "0.1.0" ]
}

@test 'version.sh  - Envar -  3: Test Major Release' {
    # prepare environment
    PRIOR_VERSION="0.0.0"
    result=$(main major release)
    [ "$result" == "1.0.0" ]
}

@test 'version.sh  - Envar -  4: Test Patch RC' {
    # prepare environment
    PRIOR_VERSION="0.0.0"
    # get new version
    result=$(echo $(main patch rc) | grep "0.0.1-rc+commit-" | wc -l)
    [ $result -eq 1 ]

}

@test 'version.sh  - Envar -  5: Test Minor RC' {
    # prepare environment
    PRIOR_VERSION="0.0.0"
    # get new version
    result=$(echo $(main minor rc) | grep "0.1.0-rc+commit-" | wc -l)
    [ $result -eq 1 ]
}

@test 'version.sh  - Envar -  6: Test Major RC' {
    # prepare environment
    PRIOR_VERSION="0.0.0"       
    # get new version
    result=$(echo $(main major rc) | grep "1.0.0-rc+commit-" | wc -l)
    [ $result -eq 1 ]
}

@test 'version.sh  - Envar -  7: Test Commit' {
    # prepare environment
    PRIOR_VERSION="0.0.0"
    # get new version
    result=$(echo $(main) | grep "0.0.0+commit-" | wc -l)
    [ $result -eq 1 ]
}

@test 'version.sh  - Envar -  8: Test Patch Release - Complex' {
    # prepare environment
    PRIOR_VERSION="0.0.0-rc+commit-BATS"
    result=$(main patch release)
    [ "$result" == "0.0.1" ]
}

@test 'version.sh  - Envar -  9: Test Minor Release - Complex' {
    # prepare environment
    PRIOR_VERSION="0.0.0-rc+commit-BATS"
    result=$(main minor release)
    [ "$result" == "0.1.0" ]
}

@test 'version.sh  - Envar - 10: Test Major Release - Complex' {
    # prepare environment
    PRIOR_VERSION="0.0.0-rc+commit-BATS"
    result=$(main major release)
    [ "$result" == "1.0.0" ]
}

@test 'version.sh  - Both  -  1: Test File and Envar' {
    # prepare environment
    PRIOR_VERSION="1.0.0"
    FILE_VERSION=$(cat ver)
    [ "$PRIOR_VERSION" == "1.0.0" ] && [ "$FILE_VERSION" == "0.0.0" ]

    # Envar overrides file
    result=$(main major release)
    FILE_VERSION=$(cat ver)
    [ "$result" == "2.0.0" ] && [ "$FILE_VERSION" == "2.0.0" ]

    # Check for idempotency
    result=$(main major release)
    FILE_VERSION=$(cat ver)
    [ "$result" == "2.0.0" ] && [ "$FILE_VERSION" == "2.0.0" ]

    # Read from File
    PRIOR_VERSION=$(cat ver)
    FILE_VERSION=$(cat ver)
    [ "$PRIOR_VERSION" == "2.0.0" ] && [ "$FILE_VERSION" == "2.0.0" ]
    result=$(main major release)
    FILE_VERSION=$(cat ver)
    [ "$result" == "3.0.0" ] && [ "$FILE_VERSION" == "3.0.0" ]

    # Empty the envar
    unset PRIOR_VERSION
    FILE_VERSION=$(cat ver)
    [ -z $PRIOR_VERSION ] && [ "$FILE_VERSION" == "3.0.0" ]
    result=$(main major release)
    FILE_VERSION=$(cat ver)
    [ "$result" == "4.0.0" ] && [ "$FILE_VERSION" == "4.0.0" ]

    PRIOR_VERSION="9.0.0"
    FILE_VERSION="0.0.1"
    [ $PRIOR_VERSION == "1.0.0" ] && [ "$FILE_VERSION" == "0.0.1" ]
    result=$(main major release)
    FILE_VERSION=$(cat ver)
    [ "$result" == "10.0.0" ] && [ "$FILE_VERSION" == "10.0.0" ]
}