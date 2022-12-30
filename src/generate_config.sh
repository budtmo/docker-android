#!/bin/bash

node_config_json=$1

if [ "$CONNECT_TO_GRID_4" = true ]; then

  #NODE CONFIGURATION FOR SELENIUM 4

  node_config_toml=config.toml

  if [ -z "$APPIUM_HOST" ]; then
    APPIUM_HOST=$(hostname -i)
  fi

  if [ -z "$APPIUM_PORT" ]; then
    APPIUM_PORT=4723
  fi

  if [ -z "$BROWSER_NAME" ]; then
    BROWSER_NAME="chrome"
  fi

  if [ -z "$PLATFORM_NAME" ]; then
    PLATFORM_NAME="android"
  fi

  #Get device names
  devices=($(adb devices | grep -oP "\K([^ ]+)(?=\sdevice(\W|$))"))
  echo "Devices found: ${#devices[@]}"

  #Create TOML configs file
  function create_configs() {
    configs=""
    for name in ${devices[@]}; do
      os_version="$(adb -s $name shell getprop ro.build.version.release | tr -d '\r')"
      configs+=$(cat <<_EOF
"1", "{\"browserName\": \"$BROWSER_NAME\", \"platformName\": \"$PLATFORM_NAME\", \"appium:platformVersion\": \"$os_version\"}"
_EOF
    )
      if [[ ${devices[-1]} != $name ]]; then
        configs+=', '
      fi
    done
  echo "$configs"
  }

#Final node configuration toml string
nodeconfig=$(cat <<_EOF
[server]
port = 5556

[node]
detect-drivers = false

[relay]
# Default Appium server endpoint
url = "http://$APPIUM_HOST:$APPIUM_PORT/wd/hub"
status-endpoint = "/status"
# Stereotypes supported by the service
configs = [
  $(create_configs)
]
_EOF
)
echo "$nodeconfig" > $node_config_toml

else

#NODE CONFIGURATION FOR SELENIUM 3

if [ -z "$PLATFORM_NAME" ]; then
  PLATFORM_NAME="Android"
fi

if [ -z "$APPIUM_HOST" ]; then
  APPIUM_HOST=$(hostname -i)
fi

if [ -z "$APPIUM_PORT" ]; then
  APPIUM_PORT=4723
fi

if [ -z "$SELENIUM_HOST" ]; then
  SELENIUM_HOST="172.17.0.1"
fi

if [ -z "$SELENIUM_PORT" ]; then
  SELENIUM_PORT=4444
fi

if [ -z "$BROWSER_NAME" ]; then
  BROWSER_NAME="android"
fi

if [ -z "$NODE_TIMEOUT" ]; then
  NODE_TIMEOUT=300
fi

#Get device names
devices=($(adb devices | grep -oP "\K([^ ]+)(?=\sdevice(\W|$))"))
echo "Devices found: ${#devices[@]}"

#Create capabilities json configs
function create_capabilities() {
  capabilities=""
  for name in ${devices[@]}; do
    os_version="$(adb -s $name shell getprop ro.build.version.release | tr -d '\r')"
    serial_number="$(adb -s $name shell getprop ro.serialno | tr -d '\r')"
    capabilities+=$(cat <<_EOF
{
    "platform": "$PLATFORM_NAME",
    "platformName": "$PLATFORM_NAME",
    "version": "$os_version",
    "browserName": "$BROWSER_NAME",
    "deviceName": "$name",
    "maxInstances": 1,
    "applicationName": "$serial_number"
  }
_EOF
    )
    if [ ${devices[-1]} != $name ]; then
      capabilities+=', '
    fi
  done
  echo "$capabilities"
}

#Final node configuration json string
nodeconfig=$(cat <<_EOF
{
  "capabilities": [$(create_capabilities)],
  "configuration": {
    "cleanUpCycle": 2000,
    "timeout": $NODE_TIMEOUT,
    "proxy": "org.openqa.grid.selenium.proxy.DefaultRemoteProxy",
    "url": "http://$APPIUM_HOST:$APPIUM_PORT/wd/hub",
    "host": "$APPIUM_HOST",
    "port": $APPIUM_PORT,
    "maxSession": 6,
    "register": true,
    "registerCycle": 5000,
    "hubHost": "$SELENIUM_HOST",
    "hubPort": $SELENIUM_PORT
  }
}
_EOF
)
echo "$nodeconfig" > $node_config_json
fi