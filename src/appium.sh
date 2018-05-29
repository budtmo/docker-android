#!/bin/bash

if [ -z "$GENY_TEMPLATE" ]; then
  GENY_TEMPLATE="/root/tmp/devices.json"
fi

if [ ! -f "$GENY_TEMPLATE" ]; then
    echo "File not found! Nothing to do!"
    exit 1
fi

contents=$(cat $GENY_TEMPLATE)

function prepare_geny_cloud() {
	# Register
	gmtool config username="${USER}" password="${PASS}"
	gmtool license register "${LICENSE}"

	# Start device(s)
	echo "Creating device(s) based on given json file..."
	for row in $(echo "${contents}" | jq -r '.[] | @base64'); do
		get_value() {
			echo ${row} | base64 --decode | jq -r ${1}
    	}

	    template=$(get_value '.template')
	    device=$(get_value '.device')

	    if [[ $template ]] && [[ $template != null ]]; then
	    	echo "Starting \"$device\" with template name \"$template\"..."
			gmtool --cloud admin startdisposable "${template}" "${device}"
	    else
	    	echo "Starting \"$device\"..."
	    	gmtool --cloud admin start "${device}"
	    fi
	done
}

function run_appium() {
	echo "Preparing appium-server..."
	CMD="appium --log $APPIUM_LOG"
	if [ ! -z "$CONNECT_TO_GRID" ]; then
		NODE_CONFIG_JSON="/root/src/nodeconfig.json"
		/root/generate_config.sh $NODE_CONFIG_JSON
		CMD+=" --nodeconfig $NODE_CONFIG_JSON"
  	fi
  	echo "Preparation is done"
  	$CMD
}

if [[ $REAL_DEVICE = true ]]; then
	run_appium
elif [[ $GENYMOTION = true ]]; then
	prepare_geny_cloud
	run_appium
else
	python3 -m src.app
fi
