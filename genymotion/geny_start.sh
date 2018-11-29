#!/bin/bash
# This script is needed because of https://www.ctl.io/developers/blog/post/gracefully-stopping-docker-containers/

types=(saas aws)

if [ -z "$TYPE" ]; then
    echo "Please specify one of following types: ${types[@]}"
    exit 1
fi
TYPE=$(echo "$TYPE" | tr '[:upper:]' '[:lower:]')

if [ -z "$TEMPLATE" ]; then
    case $TYPE in
    "${types[0]}" )
        TEMPLATE="/root/tmp/devices.json"
        ;;
    "${types[1]}" )
        TEMPLATE="/root/tmp/aws.json"
        ;;
    *)
        "Type $TYPE is not supported! Valid types: ${types[@]}"
        exit 1
        ;;
    esac
fi

if [ ! -f "$TEMPLATE" ]; then
    echo "File not found! Nothing to do!"
    exit 1
fi

echo "[geny_start] Available types: ${types[@]}"
echo "[geny_start] Selected type of deployment: $TYPE, Template file: $TEMPLATE"
export TYPE=$TYPE
export TEMPLATE=$TEMPLATE
export TYPES=${types[@]}

getAbort() {
    case $TYPE in
    "${types[0]}" )
        contents=$(cat $TEMPLATE)
        echo "ABORT SIGNAL detected! Stopping all created emulators..."
        for row in $(echo "${contents}" | jq -r '.[] | @base64'); do
            get_value() {
                echo ${row} | base64 --decode | jq -r ${1}
            }

            gmtool --cloud admin stopdisposable $(get_value '.device')
        done
        echo "Done"
        ;;
    "${types[1]}" )
        contents=$(cat $TEMPLATE)
        echo "ABORT SIGNAL detected! Detroy all EC2 instance(s)..."
        ./terraform destroy -auto-approve -lock=false
        ;;
    esac
}
trap 'getAbort; exit' EXIT

/usr/bin/supervisord --configuration supervisord.conf
