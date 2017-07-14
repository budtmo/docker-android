#!/bin/bash

function start() {
    mkdir -p $VIDEO_PATH
    sw=$(($SCREEN_WIDTH - 1))
    sh=$(($SCREEN_HEIGHT - 1))
    name="$DEVICE-$BROWSER-$(date '+%d/%m/%Y-%H:%M:%S')"
    echo "Start video recording"
    ffmpeg -video_size $swx$sh -framerate 15 -f x11grab -i ${DISPLAY} $VIDEO_PATH/$name -y
}

function stop() {
    echo "Stop video recording"
    kill $(ps -ef | grep ffmpeg)
}

function auto_record() {
    if [ ! -z $AUTO_RECORD ]; then
        if [ ${AUTO_RECORD,,} = true ]; then
            echo "Auto recording is enable. It will record the video automatically as soon as appium receive test scenario!"

            # Check if there is test running
            no_test=true
            while $no_test; do
                task=$(curl -s localhost:4723/wd/hub/sessions | jq -r '.value')
                if [ -n "$task" ]; then
                    sleep .5
                else
                    no_test=false
                    start
                fi
            done

            # Check if test is finished
            while [ $no_test = false ]; do
                task=$(curl -s localhost:4723/wd/hub/sessions | jq -r '.value')
                if [ -n "$task" ]; then
                    stop
                else
                    sleep .5
                fi
            done
        fi
    fi
}