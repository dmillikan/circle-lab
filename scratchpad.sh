manifest_file=$(openssl rand -hex 8)
echo '[
    "celsius-action-engine",
    "celsius-dashboard",
    "data-disc-sls",
    "device-gql-sls",
    "user-gql-sls"
]' > $manifest_file

order_file=$(openssl rand -hex 8)
echo '{
    "root": "apps",
    "pages": 3,
    "packages": {
        "celsius-data-storage": ["apps/celsius-data-storage/"],
        "data-disc-sls": ["apps/data-disc-sls/"],
        "device-gql-sls": ["apps/device-gql-sls/"],
        "user-gql-sls": ["apps/user-gql-sls"],
        "flespi-sparkplug-converter": ["apps/flespi-sparkplug-converter/"],
        "celsius-action-engine": ["apps/celsius-action-engine"],
        "strapi-infra": ["apps/strapi-infra"],
        "external-rest-api-sls": ["apps/external-rest-api-sls"],
        "celsius-dashboard": ["apps/celsius-dashboard/"]
    }
}' > $order_file


out_file=$(openssl rand -hex 8)

for order_item in $(jq ".packages" < "$order_file" | jq -r 'keys_unsorted[]')
do
    for manifest_item in $(jq .[] < "$manifest_file" | sed 's/\"//g')
    do
        if [ "$order_item" == "$manifest_item" ]
        then
            echo "$order_item" >> "$out_file"
        fi
    done
done

## pop the out_file
# read "$out_file"
out_file_new=$(openssl rand -hex 8)
let lc=0
for l in $(cat "$out_file")
do  
    let lc++
    if [ $lc -eq 1 ]
    then
        echo "$l"
    else
        echo "$l" >> "$out_file_new"
    fi
done

rm $order_file
rm $manifest_file
rm $out_file