# skeys='environment|version'
# svals='dev|0.3.1'

addAttribute(){
    if [ -z $skeys ]
    then
        k=$(echo "$1")
        v=$(echo "$2")
    else
        k=$(echo "|$1")
        v=$(echo "|$2")
    fi
    skeys=$(echo "$skeys$k")
    svals=$(echo "$svals$v")
}


buildJson(){
    s="$skeys
$svals"
    path=$1
    parms=$(jq -Rn --arg path "$path" '
    setpath([$path];
    ( input | split("|") ) as $keys |
    ( input | split("|") ) as $vals |
    [[$keys, $vals] | transpose[] | {key:.[0],value:.[1]}] | from_entries)
    ' <<<"$s")
    jq . <<< "$parms"
    
}

addAttribute "environment" "dev"
addAttribute "version" "0.1.0"
addAttribute "tag" "rc tag"
data=$(buildJson "parameters")
jq . <<< $data
