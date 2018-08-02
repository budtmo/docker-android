#!/bin/bash

function wait_emulator_to_be_ready () {
  boot_completed=false
  while [ "$boot_completed" == false ]; do
    status=$(adb wait-for-device shell getprop sys.boot_completed | tr -d '\r')
    echo "Boot Status: $boot_completed"

    if [ "$boot_completed" == "1" ]; then
      boot_completed=true
    else
      sleep 1
    fi      
  done
}

function install_google_play_service () {
  wait_emulator_to_be_ready
  adb install -r "/root/google_play_service.apk"
}

function disable_animation () {
  # this is for demonstration what other amazing staff can be done here
  adb shell "settings put global window_animation_scale 0.0"
  adb shell "settings put global transition_animation_scale 0.0"
  adb shell "settings put global animator_duration_scale 0.0"
}

install_google_play_service
disable_animation
