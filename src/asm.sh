#!/bin/bash

if [ -z "$REAL_DEVICE"]; then
  echo "Container is using android emulator"
else
  echo "Starting android screen mirro..."
  java -jar /root/asm.jar $ANDROID_HOME
fi
