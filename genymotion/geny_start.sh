#!/bin/bash
# This script is needed because of https://www.ctl.io/developers/blog/post/gracefully-stopping-docker-containers/

if [ -z "$GENY_TEMPLATE" ]; then
  	GENY_TEMPLATE="/root/tmp/devices.json"
fi

if [ ! -f "$GENY_TEMPLATE" ]; then
    echo "File not found! Nothing to do!"
    exit 1
fi

contents=$(cat $GENY_TEMPLATE)
getAbort() {
    echo "ABORT SIGNAL detected! Stopping all created emulators..."
    for row in $(echo "${contents}" | jq -r '.[] | @base64'); do
		get_value() {
			echo ${row} | base64 --decode | jq -r ${1}
    	}
    	
    	gmtool --cloud admin stopdisposable $(get_value '.device')
    done
    echo "Done"  
}
trap 'getAbort; exit' EXIT

/usr/bin/supervisord --configuration supervisord.conf
