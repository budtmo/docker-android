#!/bin/bash

if [ "$ATD" = true ]; then
    echo "Starting ATD..."
    java -jar /root/RemoteAppiumManager.jar -DPort=4567
fi
