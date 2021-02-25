#! /bin/bash

# cicd_scripts/parameter.sh

setup() {
    # Load our script file.
    source ./cicd_scripts/logger.sh
}

extend(){
    echo "$1, $2"
}

build_entry(){
    echo "$1:"'"'"$2"'"'
}

enclose(){
    echo "{$1}"
}

setup
a1=$(build_entry "$1" "$2")
a2=$(build_entry another one)
c=$(extend "$a1" "$a2")
h=$(enclose "$c")
jq -n "$h"

# extend $1 $2