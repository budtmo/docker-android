#!/bin/bash

if [ -z "$GENY_TEMPLATE" ]; then
  	GENY_TEMPLATE="/root/tmp/devices.json"
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
	    port=$(get_value '.port')

	    if [[ $port != null ]]; then
	    	echo "Starting \"$device\" with template name \"$template\" on port \"$port\"..."
	    	gmtool --cloud admin startdisposable "${template}" "${device}" --adb-serial-port "${port}"
	    else
	    	echo "Starting \"$device\" with template name \"$template\"..."
			gmtool --cloud admin startdisposable "${template}" "${device}"
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
	echo "Using real device"
	run_appium
elif [[ $GENYMOTION = true ]]; then
	echo "Using Genymotion"
	prepare_geny_cloud
	run_appium
else
	echo "Using Emulator"
	python3 -m src.app
fi
