#!/bin/bash

if [ -z "$REAL_DEVICE"]; then
  echo "Container is using android emulator"
else
  echo "Starting android screen copy..."
  /usr/local/bin/scrcpy
fi
