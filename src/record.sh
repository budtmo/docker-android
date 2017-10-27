#!/bin/bash

function start() {
    mkdir -p $VIDEO_PATH
    name="$(date '+%d_%m_%Y_%H_%M_%S').mp4"
    echo "Start video recording"
    ffmpeg -video_size 1599x899 -framerate 15 -f x11grab -i $DISPLAY $VIDEO_PATH/$name -y
}

function stop() {
    echo "Stop video recording"
    kill $(ps -ef | grep ffmpeg | awk '{print $2}')
}

function auto_record() {
    if [ $AUTO_RECORD ]; then
        if [ ${AUTO_RECORD,,} = true ]; then
            echo "Auto recording is enable. It will record the video automatically as soon as appium receive test scenario!"

            # Check if there is test running
            no_test=true
            while $no_test; do
                task=$(curl -s localhost:4723/wd/hub/sessions | jq -r '.value')
                if [ -n $task ]; then
                    sleep .5
                else
                    no_test=false
                    start
                fi
            done

            # Check if test is finished
            while [ $no_test = false ]; do
                task=$(curl -s localhost:4723/wd/hub/sessions | jq -r '.value')
                if [ -n $task ]; then
                    stop
                else
                    sleep .5
                fi
            done
        fi
    fi
}

$@
